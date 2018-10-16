import { Component } from 'react';
import ui from './widget-header.ui';

interface IProps {
  title: string;
}

interface IState {
}

export class HeaderWidget extends Component<IProps, IState> {
  public render() {
    return ui.apply(this);
  }
}
