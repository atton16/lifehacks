import { Component } from 'react';
import { withRouter } from 'react-router';
import { RouteComponentProps } from 'react-router-dom';
import ui from './page-foo-form.ui';

import { nameService } from '../../services/name.service';

interface IProps extends RouteComponentProps {
}

interface IState {
  name: string;
}

export class FooFormPage extends Component<IProps,IState> {
  constructor(props: IProps) {
    super(props);
    this.state = {
      name: ''
    };
    
    this.handleNameChange = this.handleNameChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  public render() {
    return ui.apply(this);
  }

  public handleNameChange(event: React.ChangeEvent<HTMLInputElement>) {
    this.setState({name: event.target.value});
  }

  public handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    nameService.setName(this.state.name);
    this.props.history.push('/');
  }
}

export const FooFormPageHOC = withRouter(FooFormPage);
