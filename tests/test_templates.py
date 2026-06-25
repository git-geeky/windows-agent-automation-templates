import json
import re
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


PRIVATE_PATTERNS = [
    r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}",
    r"BEGIN [A-Z ]*PRIVATE KEY",
    r"api[_-]?key\s*[:=]\s*['\"][^'\"]+",
    r"token\s*[:=]\s*['\"][^'\"]+",
    r"private\.example",
]


class TemplateTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(__file__).resolve().parents[1]

    def test_json_templates_parse(self):
        for path in self.root.rglob("*.json"):
            json.loads(path.read_text(encoding="utf-8"))

    def test_task_xml_template_parses_after_placeholder_fill(self):
        path = self.root / "task-xml" / "AgentTask.template.xml"
        text = path.read_text(encoding="utf-8")
        manifest = json.loads((self.root / "templates" / "task.restore.example.json").read_text(encoding="utf-8"))
        replacements = {f"{{{{{key}}}}}": str(value) for key, value in manifest.items()}
        for marker, value in replacements.items():
            text = text.replace(marker, value)
        ET.fromstring(text.encode("utf-16"))

    def test_task_restore_manifest_covers_template_markers(self):
        text = (self.root / "task-xml" / "AgentTask.template.xml").read_text(encoding="utf-8")
        manifest = json.loads((self.root / "templates" / "task.restore.example.json").read_text(encoding="utf-8"))
        markers = set(re.findall(r"{{([^}]+)}}", text))
        self.assertEqual(markers, set(manifest))

    def test_no_private_markers(self):
        searchable = [".md", ".ps1", ".vbs", ".json", ".xml"]
        offenders = []
        for path in self.root.rglob("*"):
            if ".git" in path.parts or path.suffix.lower() not in searchable:
                continue
            text = path.read_text(encoding="utf-8")
            for pattern in PRIVATE_PATTERNS:
                if re.search(pattern, text):
                    offenders.append(f"{path.relative_to(self.root)}:{pattern}")
        self.assertEqual(offenders, [])


if __name__ == "__main__":
    unittest.main()
