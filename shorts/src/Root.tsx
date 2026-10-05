import {Composition,getInputProps} from 'remotion';
import {Short} from './Short';
import {catalog} from './catalog';
export function Root(){const props=getInputProps();return <>{catalog.map(config=><Composition key={config.id} id={config.id} component={Short} width={config.width} height={config.height} fps={config.fps} durationInFrames={Math.round(config.duration*config.fps)} defaultProps={{config,debugSafeArea:Boolean(props.debugSafeArea)}}/>)}</>}
