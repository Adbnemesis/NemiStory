from pathlib import Path
from io import BytesIO
import importlib.util
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("preview_server", ROOT / "previews/serve.py")
server = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(server)


def request(path, headers=None):
    handler = server.PreviewHandler.__new__(server.PreviewHandler)
    handler.path, handler.headers = path, headers or {}
    handler.response_headers = {}
    handler.send_response = lambda code: setattr(handler, "status", code)
    handler.send_header = lambda key, value: handler.response_headers.update({key: value})
    handler.end_headers = lambda: None
    handler.send_error = lambda code, message: setattr(handler, "status", code)
    return handler


class PreviewServerTests(unittest.TestCase):
    def test_default_document(self):
        handler = request("/")
        stream = handler.send_head()
        with stream:
            self.assertIn(b"360 degree story viewport", stream.read())
        self.assertEqual(handler.status, 200)

    def test_forward_range_and_suffix(self):
        expected = (ROOT / "previews/index.html").read_bytes()
        for value, content in [("bytes=0-31", expected[:32]), ("bytes=-32", expected[-32:])]:
            handler = request("/previews/index.html", {"Range": value})
            stream, output = handler.send_head(), BytesIO()
            with stream:
                handler.copyfile(stream, output)
            self.assertEqual(handler.status, 206)
            self.assertEqual(output.getvalue(), content)
            self.assertEqual(handler.response_headers["Content-Length"], "32")

    def test_invalid_and_unsatisfiable_range(self):
        for value in ("bytes=0-2,8-10", "bytes=999999999-", "bytes=-"):
            handler = request("/previews/index.html", {"Range": value})
            self.assertIsNone(handler.send_head())
            self.assertEqual(handler.status, 416)

    def test_traversal_and_directory_listing_denied(self):
        handler = request("/../../AGENTS.md")
        self.assertIsNone(handler.send_head())
        self.assertEqual(handler.status, 404)
        handler = request("/episodes/")
        self.assertIsNone(handler.send_head())
        self.assertEqual(handler.status, 404)


if __name__ == "__main__":
    unittest.main()
