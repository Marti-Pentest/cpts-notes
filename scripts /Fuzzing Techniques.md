# File Upload Fuzzing Techniques

## 🎯 Objective

Generate multiple filename variations to bypass upload filters.

Useful for:
- Extension bypass
- Special character injection
- Filter evasion

---

## 🧪 Filename Fuzzing

Generate variations with special characters:

```bash
for char in "%20" "%0a" "/" "." ";" ","; do
  echo "shell${char}.php.jpg"
done
