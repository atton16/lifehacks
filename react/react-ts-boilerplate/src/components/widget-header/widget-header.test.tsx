import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { HeaderWidget } from './widget-header';

it('renders without crashing', () => {
  const div = document.createElement('div');
  ReactDOM.render(<HeaderWidget title="" />, div);
  ReactDOM.unmountComponentAtNode(div);
});
