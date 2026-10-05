import {normalize} from '../shared/utilities/normalize';
import legDay from '../adb/compositions/leg-day';
import machine from '../adb/compositions/machine';
import tinyChange from '../nemi/compositions/tiny-change';
import quickSketch from '../nemi/compositions/quick-sketch';
export const catalog=[legDay,machine,tinyChange,quickSketch].map(normalize);
