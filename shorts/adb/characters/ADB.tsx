import {Character} from '../../shared/utilities/Character';
import type {ComponentProps} from 'react';
export const ADB=(props:Omit<ComponentProps<typeof Character>,'author'>)=><Character {...props} author="adb"/>;
