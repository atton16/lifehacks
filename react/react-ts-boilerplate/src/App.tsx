import * as React from 'react';
import { Route, Switch } from "react-router-dom";
import 'symbol-observable';

import { FooFormPageHOC } from './components/page-foo-form/page-foo-form';
import { HelloWorldPageHOC } from './components/page-hello-world/page-hello-world';

// Recompose setup
import { setObservableConfig } from 'recompose';
import { from } from 'rxjs';
setObservableConfig({
  fromESObservable: from as any,
});

class App extends React.Component {
  public render() {
    return (
      <Switch>
        <Route exact={true} path="/" component={HelloWorldPageHOC} />
        <Route path="/foo-form" component={FooFormPageHOC} />
      </Switch>
    );
  }
}

export default App;
