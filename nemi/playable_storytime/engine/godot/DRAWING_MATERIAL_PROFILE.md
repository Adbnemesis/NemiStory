# Drawing-world material and context profile

This isolated renderer uses Nemi's cream paper, warm dark contours, rounded
held marks and selective soft washes. It preserves canonical character rigs,
production-stage timing and the existing four-wall projection. New fixed
material/context geometry below extends the existing drawing renderer rather
than introducing another player or animation system.

Source coordinates are1920×1080. `p` is the object's authored x/y. Fixed
context art does not accept size, rotation, path or animation fields.

| Kind | Geometry relative to p | Contact and intent |
|---|---|---|
| `ruler` | Top x−350..290,y−70..0;15px front thickness; sparse tick groups | Front edge p.y; giant drawing-tool scale, held |
| `ink_bottle` | Body x−60..60,y−195..0; closed cap reaches y−255; small base shadow | Base p.y; softly washed glass, bounded dark ink, no extra label |
| `paper_stack` | Top x−180..200,y−160..−100; front layers to0 | Base p.y; four stable sheet edges establish real paper thickness |
| `paper_clip` | Flat open-ended wire loop x−55..57,y−25..33 | Place on stack top; e.g.[1440,745] beside a stack at[1420,905] |

`text` is absent or empty on these four context kinds. Named environment
actions cannot target them. Existing generic author, world bounds,
continuity, material-state, reveal and path validation still applies. New
context art is painted before the canonical actor. Its fixed held geometry
has no per-frame randomness, cycling opacity or bobbing.

## Unfinished bridge

For a bridge at p=[1420,820], the near top deck is the quad[1090,760],
[1350,760],[1390,905],[1050,905]. A30px front thickness sits below905.
The back rail rises to560; the front rail to650. Four plank seams span the
broad top plane. The separated far page bank occupies x1710..1870 with a
top plane y760..905. The span x1390..1710 remains empty, with a few faint
pencil-guide dashes. The bank is not a finished bridge support. Cream bank,
tan deck wash, warm contours and the limited rose broken edge carry the
material distinction.

The existing finite `bridge_break`/`rewind` events move only the unfinished
near structure and reconstruct the same held state on a seek. The near
structure's front sole plane is p.y+85. The choice label anchor is p+[0,−350]
so the number remains above the taller silhouette. This geometry neither
walks nor moves the canonical character.

## Broad folding paper

For a paper tab at p=[500,837], front hinge H=[240,905]. For fold progress
f∈[0,1], theta=lerp(−PI/2,0,f), F=H+560[cos(theta),sin(theta)], and
D=[220(1−f),−160f]. The broad face has corners[H,H+D,F+D,F], with one
slightly torn free corner and a crosswise crease near the hinge. At f=0 it
occupies x240..460,y345..905. At f=1 it occupies x240..800,y745..905.
The front edge remains exactly y905 in the completed state, supporting the
authored x320 arrival. Separate page-bank lips touch the endpoints.

The front thickness offset interpolates from[12,0] upright to[0,30] folded.
This avoids a zero-area polygon at the upright endpoint. The free side's
thickness uses[10,19], remaining nondegenerate at both endpoints. Thickness
and short contact shadows are below the supported front plane; crease and
fibre marks distinguish paper from wooden planks. The existing label anchor
p+[0,−560] stays above the eventual actor's hair.

The existing finite `tab_fold` event owns this one continuous face; no
ghost copies or opacity-only reveal is used. `folded:true` selects its
completed held geometry. Runtime proof must inspect f=0, mid-fold and f=1,
soles before/after arrival, normal projected views and a contact-wide shot.
During the turn, the projected face changes orientation through one edge-on
instant near f=.55. A paper-only area/triangulation guard draws its contour
without fill whenever projected area is under280 source pixels squared or
triangulation is unavailable; it never submits a zero-area filled polygon.
This profile and its example describe supported geometry, not render review
or native YouTube approval.
