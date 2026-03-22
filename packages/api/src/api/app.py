from fastapi import FastAPI

app = FastAPI(title="magpie")


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
