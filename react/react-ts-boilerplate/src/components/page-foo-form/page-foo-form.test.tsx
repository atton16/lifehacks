import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { MemoryRouter } from 'react-router-dom';
import { FooFormPageHOC } from './page-foo-form';

it('renders without crashing', () => {
  const div = document.createElement('div');
  ReactDOM.render(
    <MemoryRouter>
      <FooFormPageHOC />
    </MemoryRouter>
  , div);
  ReactDOM.unmountComponentAtNode(div);
});
