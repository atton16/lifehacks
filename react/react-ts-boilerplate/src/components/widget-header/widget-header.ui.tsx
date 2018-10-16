import * as React from 'react';

import { HeaderWidget } from './widget-header';
import './widget-header.css';

import logo from '../../media/logo.svg';

export default function (this: HeaderWidget) {
  return (
    <div className="widget-header">
      <header className="widget-header-header">
        <img src={logo} className="widget-header-logo" alt="logo" />
        <h1 className="widget-header-title">{this.props.title}</h1>
      </header>
    </div>
  );
};
