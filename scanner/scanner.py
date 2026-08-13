import os

found = False

for root, dirs, files in os.walk("."):
    for file in files:
        if file.endswith(".tf"):
            path = os.path.join(root, file)

            with open(path, "r") as f:
                content = f.read()

            if "0.0.0.0/0" in content:
                print(f"ALERTA: {path} contiene 0.0.0.0/0")
                found = True
            else:
                print(f"OK: {path}")

if found:
    exit(1)

print("Análisis terminado correctamente.")