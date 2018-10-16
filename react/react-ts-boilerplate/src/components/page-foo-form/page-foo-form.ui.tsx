import * as React from 'react';
import { Link } from 'react-router-dom';

import { HeaderWidget } from '../widget-header/widget-header';
import { FooFormPage } from './page-foo-form';
import './page-foo-form.css';

export default function (this: FooFormPage) {
  return (
    <div>
      <HeaderWidget title="Foo Form" />
      <div className="container mt-3">
        <div className="row">
          <div className="col-12 col-sm-8 offset-sm-2 col-md-6 offset-md-3">
            <form onSubmit={this.handleSubmit}>
              <div className="form-group">
                <label>Name</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="John"
                  onChange={this.handleNameChange} />
              </div>
              <div className="form-group">
                <input
                  type="submit"
                  className="btn btn-primary"
                  value="Save" />
                <Link to="/"
                  className="ml-2 btn btn-outline-primary"
                  role="button">
                  Back to Home
                </Link>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};
