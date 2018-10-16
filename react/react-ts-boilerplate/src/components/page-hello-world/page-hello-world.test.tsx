import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom';
import { HelloWorldPageHOC } from './page-hello-world';

it('renders without crashing', () => {
  const div = document.createElement('div');
  ReactDOM.render(
    <MemoryRouter>
      <HelloWorldPageHOC />
    </MemoryRouter>
  , div);
  ReactDOM.unmountComponentAtNode(div);
});
