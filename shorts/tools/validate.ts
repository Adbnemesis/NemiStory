import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';
import {catalog} from '../src/catalog';
import {validate} from './validation';
const root=resolve(fileURLToPath(new URL('..',import.meta.url)));const errors=catalog.flatMap(c=>validate(c,root));
if(errors.length){console.error(errors.join('\n'));process.exit(1)}console.log(`Validated ${catalog.length} Shorts: timeline, assets, hashes, contact controls, event links and source coverage.`);
