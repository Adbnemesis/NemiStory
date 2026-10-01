"""Exercise actual gate failures using isolated documents, not real episode edits."""
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import uuid
import preflight as p
from validate_scene import validate

class GateTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(prefix='story-preflight-')
        self.root=Path(self.temp.name).resolve()
        (self.root/'docs/animation/preflight').mkdir(parents=True)
        self.manifest={'version':1,'common':['shared.md'],'characters':{'nemi':['nemi.md'],'adb':['adb.md']},'features':{'props':['props.md'],'sfx':['sfx.md'],'live_ink':['ink.md']},'precedence':'Current workflows first.'}
        p.save(self.root/p.MANIFEST,self.manifest);p.save(self.root/p.HISTORICAL,{})
        for name in ['shared','nemi','adb','props','sfx','ink']:(self.root/(name+'.md')).write_text((name+' concrete guidance.\n')*3)
        (self.root/'shared.md').write_text('Current shared guidance.\n'*400)
        self.folder=self.root/'production';p.initialize(self.folder,['nemi'],[],self.root)
        self.spec={'version':2,'actors':[{'author':'nemi'}],'props':[],'sfx':[],'drawings':[]}
        self.path=self.folder/'scene.json';p.save(self.path,self.spec)
    def tearDown(self):self.temp.cleanup()
    def complete(self):
        _,_,data=p.load(self.folder,self.root)
        for doc in p.requirements(data['authors'],data['features'],self.root):
            for part in range(1,len(p.document_chunks(self.root/doc))+1):p.deliver(self.folder,doc,part,self.root)
            p.acknowledge(self.folder,doc,'Synthetic test note: hold the reaction while the prop settles.',self.root)
    def test_pending_then_complete(self):
        with self.assertRaisesRegex(ValueError,'incomplete'):p.enforce(self.path,self.spec,self.root)
        self.complete();p.enforce(self.path,self.spec,self.root)
    def test_partial_read_and_empty_note(self):
        p.deliver(self.folder,'shared.md',1,self.root)
        with self.assertRaisesRegex(ValueError,'all current parts'):p.acknowledge(self.folder,'shared.md','A sufficiently long application note for this test.',self.root)
        p.deliver(self.folder,'shared.md',2,self.root)
        with self.assertRaisesRegex(ValueError,'concrete'):p.acknowledge(self.folder,'shared.md','done',self.root)
    def test_doc_edit_invalidates(self):
        self.complete();(self.root/'nemi.md').write_text('Changed instructions.')
        with self.assertRaisesRegex(ValueError,'nemi.md'):p.enforce(self.path,self.spec,self.root)
    def test_new_manifest_requirement_invalidates(self):
        self.complete();self.manifest['common'].append('props.md');p.save(self.root/p.MANIFEST,self.manifest)
        with self.assertRaisesRegex(ValueError,'props.md'):p.enforce(self.path,self.spec,self.root)
    def test_guest_and_features_cannot_be_omitted(self):
        self.complete();self.spec['actors'].append({'author':'adb'})
        with self.assertRaisesRegex(ValueError,'Character added'):p.enforce(self.path,self.spec,self.root)
        _,path,data=p.load(self.folder,self.root);data['authors'].append('adb');p.save(path,data)
        with self.assertRaisesRegex(ValueError,'adb.md'):p.enforce(self.path,self.spec,self.root)
        self.complete();self.spec['sfx']=[{'file':'some.wav'}]
        with self.assertRaisesRegex(ValueError,'additional features'):p.enforce(self.path,self.spec,self.root)
    def test_copied_record_fails(self):
        self.complete();other=self.root/'other';shutil.copytree(self.folder,other)
        with self.assertRaisesRegex(ValueError,'copied'):p.enforce(other/'scene.json',self.spec,self.root)
    def test_only_exact_historical_spec_exempt(self):
        p.save(self.root/p.HISTORICAL,{str(self.path.relative_to(self.root)):p.digest(self.path)})
        p.enforce(self.path,self.spec,self.root)
        self.path.write_text(self.path.read_text()+'\n')
        with self.assertRaisesRegex(ValueError,'incomplete'):p.enforce(self.path,self.spec,self.root)
    def test_routes_and_dedup(self):
        nemi=p.requirements(['nemi'],[],self.root);adb=p.requirements(['adb'],[],self.root)
        self.assertNotIn('adb.md',nemi);self.assertNotIn('nemi.md',adb)
        both=p.requirements(['nemi','adb'],[],self.root)
        self.assertEqual(both.count('shared.md'),1)
    def test_old_episode_paths_rejected(self):
        with self.assertRaisesRegex(ValueError,'separate new'):p.initialize(self.root/'nemi/episodes/new',['nemi'],[],self.root)

class IntegrationTests(unittest.TestCase):
    def test_starter_creates_pending_record(self):
        name='gate_test_'+uuid.uuid4().hex[:12]
        folder=p.ROOT/'common/storytime/examples'/name
        try:
            run=subprocess.run(['python3',str(p.ROOT/'tools/storytime/new_scene.py'),'--author','adb','--name',name],capture_output=True,text=True)
            self.assertEqual(run.returncode,0,run.stderr)
            self.assertEqual(p.read_json(folder/'preflight.json')['authors'],['adb'])
            with self.assertRaisesRegex(ValueError,'incomplete'):validate(folder/'scene.json',structure_only=True)
        finally:
            if folder.exists():shutil.rmtree(folder)
    def test_real_file_validator_and_renderer_gate(self):
        # A copied historical scene must not inherit its export exemption.
        with tempfile.TemporaryDirectory(prefix='gate-integration-',dir=p.ROOT/'renders') as tmp:
            folder=Path(tmp);spec=folder/'scene.json'
            spec.write_text((p.ROOT/'common/storytime/examples/story_review_48s/scene.json').read_text())
            with self.assertRaisesRegex(ValueError,'Missing preflight'):validate(spec,structure_only=True)
            run=subprocess.run(['python3',str(p.ROOT/'tools/storytime/render_scene.py'),'--spec',str(spec),'--output',str(folder/'no.mp4'),'--godot','/does/not/exist'],capture_output=True,text=True)
            self.assertNotEqual(run.returncode,0);self.assertIn('Missing preflight',run.stderr);self.assertFalse((folder/'no.mp4').exists())
    def test_real_manifest_paths_and_historical_proof(self):
        for a in ['nemi','adb']:
            for doc in p.requirements([a],['props','sfx','live_ink']):self.assertTrue((p.ROOT/doc).is_file(),doc)
        validate(p.ROOT/'common/storytime/examples/story_review_48s/scene.json',structure_only=True)

if __name__=='__main__':unittest.main()
