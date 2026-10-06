"""Render the actual optional full-body Godot drawings for visual inspection.
No production spec, audio, original rig or accepted export is modified.
"""
from pathlib import Path
import argparse, subprocess, tempfile

ROOT = Path(__file__).resolve().parents[2]
GODOT = Path('/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot')
SOURCE = '''extends SceneTree
const Art = preload("res://shorts/godot/DynamicPoseArt.gd")
const POSES = ["neutral","contrapposto","recoil","crouch","lean_in","folded","wide","groove_left","groove_right","celebrate"]
func _init() -> void: call_deferred("run")
func label(parent: Node,text: String,at: Vector2) -> void:
	var l = Label.new();l.text=text;l.position=at;l.add_theme_font_size_override("font_size",20)
	l.add_theme_color_override("font_color",Color("#383239"));parent.add_child(l)
func build(author: String,contact: bool) -> Node2D:
	var stage = Node2D.new();root.add_child(stage)
	var bg = Polygon2D.new();bg.polygon=PackedVector2Array([Vector2.ZERO,Vector2(1800,0),Vector2(1800,1300),Vector2(0,1300)])
	bg.color=Color("#e8e8e5");stage.add_child(bg)
	for i in range(10):
		var art = Art.new();art.author=author;art.body_pose=POSES[i]
		art.position=Vector2(180+360*(i%5),330+650*(i/5));art.scale=Vector2(.69,.69)
		art.view="threequarter" if i%2 == 1 else "front";art.emotion="smile"
		art.action="rest";art.shading=.28
		if POSES[i] == "celebrate": art.action="peace"
		if contact:
			art.action=["listen","phone","book_show","chin","sketch","chin","glasses","phone_up","heart_hand","wave"][i]
			art.head_angle=4;art.pose_progress=1
		stage.add_child(art);label(stage,author+" / "+POSES[i]+(" / "+art.action if contact else ""),Vector2(15+360*(i%5),610+650*(i/5)))
	return stage
func run() -> void:
	root.size=Vector2i(1800,1300);root.content_scale_size=Vector2i(1800,1300)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	var out=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):out=arg.trim_prefix("--out=")
	for author in ["nemi","adb"]:
		for contact in [false,true]:
			var stage=build(author,contact)
			await process_frame
			RenderingServer.force_draw.call_deferred(false,1.0/30)
			await process_frame
			root.get_texture().get_image().save_png(out+"/"+author+("-contact" if contact else "-body")+".png")
			stage.queue_free();await process_frame
	print("POSE STUDY COMPLETE")
	quit()
'''

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, default=ROOT/'shorts/review/pose-study03')
    args = ap.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='ink-pose-study-') as work:
        work = Path(work)
        (work/'shorts').symlink_to(ROOT/'shorts', target_is_directory=True)
        (work/'project.godot').write_text('config_version=5\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
        (work/'study.gd').write_text(SOURCE)
        p = subprocess.run([str(GODOT),'--path',str(work),'--script','res://study.gd','--','--out='+str(out)],text=True,capture_output=True)
        (out/'capture.log').write_text(p.stdout+p.stderr)
        if p.returncode or any(x in p.stdout+p.stderr for x in ('SCRIPT ERROR:','Parse Error:','ERROR:')):
            raise SystemExit(f'Godot study failed (exit {p.returncode}).\n'+p.stdout+p.stderr)
        assert 'POSE STUDY COMPLETE' in p.stdout
    print(out)
if __name__ == '__main__': main()
