import * as React from 'react';
import { Link } from 'react-router-dom';

import { HeaderWidget } from '../widget-header/widget-header';
import { HelloWorldPage } from './page-hello-world';
import './page-hello-world.css';

export default function (this: HelloWorldPage) {
  let paragraph;
  if (this.props.nameIsDirty) {
    paragraph =
      <p className="text-center">
        Your name is {this.props.name}. <Link to="/foo-form">Click here</Link> to change it.
      </p>
    ;
  } else {
    paragraph = 
      <p className="text-center">
        Get started by stating <Link to="/foo-form">your name</Link>
      </p>
    ;
  }
  return (
    <div>
      <HeaderWidget title="Hello World" />
      <div className="container">
        <div className="row">
          <div className="col-12">
            {paragraph}
          </div>
        </div>
      </div>
    </div>
  );
};
