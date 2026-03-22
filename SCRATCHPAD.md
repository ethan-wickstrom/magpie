class Chat(dspy.Signature):
    """Given the context of the conversation history, respond to the user's message by producing an assistant message"""

    input:
    - conversation_history: dspy.History = dspy.InputField(desc="The conversation history")
    - user_message: str = dspy.InputField(desc="The user's message")
    
    output:
    - assistant_message: str = dspy.OutputField(desc="The assistant's response")

class CheckCategory(dspy.Signature):
    """Given the conversation history and the user's message, check if the user's message is relevant to the given preference category.
    Return a boolean indicating relevance and a brief explanation."""
    
    input:
    - conversation_history: dspy.History = dspy.InputField(desc="The conversation history")
    - user_message: str = dspy.InputField(desc="The user's message")
    - preference_category: str = dspy.InputField(desc="The category to check")
    - category_preferences: list[str] = dspy.InputField(desc="The user's current preferences for the category, if any")
    
    output:
    - is_relevant: bool = dspy.OutputField(desc="Whether the user's message is about the category")
    - why: str = dspy.OutputField(desc="1-2 sentences explaining WHY the user's message is or is not about the category")

NOTE:
Use the map function to apply CheckCategory to each category in the set of current categories.
Return a list of booleans and reasons, one for each category.

class UpdateCategory(dspy.Signature):
    """Given the conversation history and the user's message, update the user's preferences regarding the category.
    Analyzing the conversation history, determine if the user's preferences regarding the category have changed."""
    
    input:
    - conversation_history: dspy.History = dspy.InputField(desc="The conversation history")
    - user_message: str = dspy.InputField(desc="The user's message")
    - preference_category: str = dspy.InputField(desc="The category to update")
    - category_preferences: list[tuple[str, str]] = dspy.InputField(desc="The user's current preferences for the category, if any (format: [(preference_id, preference), ...])")
    
    output:
    - preferences_to_add: list[str] = dspy.OutputField(desc="New preferences to add for this category, if any")
    - preference_ids_to_remove: list[str] = dspy.OutputField(desc="IDs of existing preferences to remove, if any")
    - why: str = dspy.OutputField(desc="1-2 sentences explaining WHY these changes were or were not made")

# Design for the Smallest Forward Passes

Design each LLM forward pass to perform one operation on one item. Use programmatic control flow to apply that operation across collections. The signature is `CheckCategory`, not `CheckCategories`. The loop is Python, not in a prompt derived from signature.

Each forward pass receives fewer input tokens, produces fewer output tokens, addresses a simpler decision, and maps to a more constrained output space. A 7B model can reliably answer "is this message about food preferences?" given one category and one message. It cannot reliably answer "which of these 12 categories does this message relate to?" because that requires holding multiple definitions in working memory, comparing each against the input, and emitting a structured multi-item response in one generation.

Handing a model a list delegates the iteration strategy to the model's reasoning. The model must decide how to traverse the list, handle each item, and aggregate results. These are control flow decisions. Control flow inside a language model's token stream is unverifiable, non-deterministic, and opaque. Control flow in Python is inspectable, deterministic, and testable.

This changes what is optimizable. DSPy optimizers operate on individual modules. When a module does one thing, the optimizer can learn a prompt that makes that one thing reliable. When a module does twelve things, the optimizer must find a prompt that improves all twelve simultaneously. GEPA (Agrawal et al., 2025) reflects on trajectories to diagnose problems and propose prompt updates. Simpler trajectories yield clearer diagnoses and more transferable lessons.

Metacognitive Reuse (Didolkar et al., 2025) identifies a second consequence. Atomic operations produce recurring reasoning patterns that compress into reusable "behaviors," cutting reasoning tokens by up to 46% without accuracy loss. A monolithic call produces a unique, tangled trace every time, which resists compression.

Replit's Decision-Time Guidance (Li et al., 2026) identifies a third. On long trajectories, adding more instructions to a single prompt has diminishing and then negative returns. Instructions compete for attention. Atomic forward passes are the module-level equivalent of their solution: each pass receives only the context relevant to its single operation.

Consider the weak-model forcing function: starting development with a 7B model is a design discipline that makes decomposition non-optional. A 7B model cannot process a list of categories in one pass with acceptable accuracy. You are forced to design `CheckCategory` rather than `CheckCategories`.

Once the system works at 7B, scaling to a larger model produces measurable information. You can quantify the per-item accuracy gain, identify which items the smaller model struggles with, and determine whether the larger model's advantage comes from better per-item reasoning or emergent ability on harder edge cases. The decomposition isolates the variable.

Starting with a 70B model and a monolithic signature produces a system that works but that you cannot diagnose, cannot cheaply optimize, and cannot downscale.

## The struct padding analogy

This resembles optimizing struct layout in low-level languages. A struct's effective size is the sum of its field sizes plus padding bytes the compiler inserts for memory alignment. Reordering fields changes the cost without changing the data.

An LLM forward pass has an analogous cost structure. The "fields" are the sub-tasks packed into a single call. The "padding" is the reasoning overhead the model generates to manage transitions between sub-tasks: restating context, tracking progress, handling multi-item output format. This padding consumes tokens, occupies context, and introduces failure modes. It grows non-linearly as items increase.

Decomposing to one item per forward pass eliminates the padding. Each call is a packed struct with no alignment waste. The total token cost across N calls may be lower than one monolithic call because inter-item bookkeeping tokens vanish.

The analogy extends to type selection. In low-level programming, you choose `uint8_t` over `int32_t` when the value fits in a byte. In LLM pipeline design, you choose the smallest signature that can represent the operation. `CheckCategory` returns a `bool` and a `str`, not `list[bool]`. Smaller output types constrain generation more tightly, reducing the space of possible wrong outputs.

Targeting a 7B model is the equivalent of targeting an embedded platform with 16KB of RAM. The constraints force optimal packing. When you later deploy to a larger platform, the efficient layout still works, and you have headroom for features rather than waste.

## The boundary condition

Decomposition becomes counterproductive when items are not independent. If checking "food preferences" requires knowing whether the message also relates to "dietary restrictions" because the categories overlap, processing each in isolation may produce contradictions. The correct response is not to collapse back to a monolithic call but to add a downstream reconciliation step: another atomic module that takes per-category results and resolves conflicts. The control flow remains in Python. The model still does one thing per forward pass. The one thing is a different thing.