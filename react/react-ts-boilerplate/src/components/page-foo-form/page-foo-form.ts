import { Component } from 'react';
import { withRouter } from 'react-router';
import { RouteComponentProps } from 'react-router-dom';
import ui from './page-foo-form.ui';

import { nameService } from '../../services/name.service';
import required from '../../validators/required';

interface IProps extends RouteComponentProps {
}

interface IState {
}

export class FooFormPage extends Component<IProps,IState> {
  constructor(props: IProps) {
    super(props);
    
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  public render() {
    return ui.apply(this);
  }

  public handleSubmit(values: any, actions: any) {
    actions.setSubmitting(false);
    if (!required(values.name)) {
      actions.setErrors({name: 'Name is required'});
      return;
    }

    nameService.setName(values.name);
    this.props.history.push('/');
  }
}

export const FooFormPageHOC = withRouter(FooFormPage);
