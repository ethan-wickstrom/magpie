from pydantic import BaseModel


class UserProfile(BaseModel):
    """A collected user profile."""

    name: str
    interests: list[str] = []
