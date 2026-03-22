
import dspy.signatures
from dspy import History

"""Using context of the conversation history and user's message, respond to the user's message 
by producing an assistant message"""
class Chat(dspy.Signature):
    conversation_history: dspy.History = dspy.InputField(desc="The conversation history")
    user_message: str = dspy.InputField(desc="The user's message")
    assistant_message: str = dspy.OutputField(desc="The response to the user message")

""""Given context of the conversation history and user's message, check if the user's message 
is relevant to the given preference category. Return a boolean indicating relevance and a 
brief explanation for the relevance decision.
Use map function to apply CheckCategory to each category in the set of current categories. 
Return a list of booleans and reasons for each category."""
class Category(dspy.Signature):
    conversation_history: dspy.History = dspy.InputField(desc="The conversation history")
    user_message: str = dspy.InputField(desc="The user's message")
    category_preferences: list[str] = dspy.InputField(desc="The user's category preferences, if any")
    preference_category: str = dspy.InputField(desc="The category to check")
    is_relevant: bool = dspy.OutputField(desc="Whether the category is relevant")
    why: str = dspy.OutputField(desc="The reason for the category relevance(1-2 sentences)")

""" Given context of the conversation history and user's message, update 
the user's preferences for a given category by adding relevant new information
and removing irrelevant information. Return the updated preferences and a brief 
explanation for the update decision."""
class UpdateCategory(dspy.Signature):
    conversation_history: dspy.History = dspy.InputField(desc="The conversation history")
    user_message: str = dspy.InputField(desc="The user's message")
    category_preferences: list[str] = dspy.InputField(desc="The user's category preferences, if any(format: [(preference_id, preference), ...])")
    preference_category: str = dspy.InputField(desc="The category to update")
    new_preferences: list[str] = dspy.OutputField(desc="New preferences to add for category, if any")
    preference_ids_to_remove: list[str] = dspy.OutputField(desc="Preference ids to remove for category, if any")
    why: str = dspy.OutputField(desc="Reason for the category preference update (1-2 sentences)")

