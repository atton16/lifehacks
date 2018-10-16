import { Component } from 'react';
import ui from './page-hello-world.ui';

interface IProps {
  name: string;
  nameIsDirty: boolean;
}

interface IState {

}

export class HelloWorldPage extends Component<IProps, IState> {
  public render() {
    return ui.apply(this);
  }
}

import { mapPropsStream } from 'recompose';
import { combineLatest } from 'rxjs';

import { nameService } from '../../services/name.service';

export const HelloWorldPageHOC = mapPropsStream(props$ => {
  return combineLatest(
    props$ as any,
    nameService.name$,
    nameService.dirty$,
    (props, name, dirty) => {
      return ({
        ...props,
        name,
        nameIsDirty: dirty,
      });
    }
  )
})(HelloWorldPage as any);