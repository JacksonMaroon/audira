# Audira UI

SwiftUI macOS shell inspired by the Aiko screens.

## Run

Open the folder in Xcode (File > Open), select the AikoCanary target, and run.

Or build from the CLI:

```bash
swift run
```

## Notes

- Import, drag/drop, and recording are wired to the Canary CLI.
- Defaults assume `~/canary-mlx/.venv/bin/python` and `~/canary-mlx/canary-1b-v2-mlx`.
- Override with environment variables:
  - `CANARY_MLX_PYTHON` (path to python)
  - `CANARY_MODEL` (path to model folder)
  - `CANARY_MLX_ROOT` (path to `canary-mlx` repo, for module resolution)
- Microphone access may require permission in System Settings > Privacy & Security.
