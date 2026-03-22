import dspy


class ExtractInterests(dspy.Signature):
    """Extract user interests from a text snippet."""

    text: str = dspy.InputField(desc="A text snippet about a user")
    interests: list[str] = dspy.OutputField(desc="A list of extracted interests")


class InterestExtractor(dspy.Module):
    def __init__(self) -> None:
        self.extract = dspy.ChainOfThought(ExtractInterests)

    def forward(self, text: str) -> dspy.Prediction:
        return self.extract(text=text)
