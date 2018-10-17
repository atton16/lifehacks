import * as React from 'react';

import { ErrorMessage, Field, Form, Formik, FormikProps } from 'formik';
import { Link } from 'react-router-dom';

import { HeaderWidget } from '../widget-header/widget-header';
import { FooFormPage } from './page-foo-form';
import './page-foo-form.css';

export default function (this: FooFormPage) {
  const renderForm = (props: FormikProps<any>): React.ReactNode => {
    return (
      <Form>
        <div className="form-group">
          <label>Name</label>
          <Field
            type="text"
            className={`
              form-control ${props.touched.name && props.errors.name ? 'is-invalid' : ''}
            `}
            name="name"
            placeholder="John"
          />
          <ErrorMessage name="name">
            {errMsg => <div className="invalid-feedback">{errMsg}</div>}
          </ErrorMessage>
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
      </Form>
    );
  }

  return (
    <div>
      <HeaderWidget title="Foo Form" />
      <div className="container mt-3">
        <div className="row">
          <div className="col-12 col-sm-8 offset-sm-2 col-md-6 offset-md-3">
            <Formik
              initialValues={{name: ''}}
              onSubmit={this.handleSubmit}
              render={renderForm}
            />
          </div>
        </div>
      </div>
    </div>
  );
};
