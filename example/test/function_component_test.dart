import 'dart:html';

import 'package:react/hooks.dart';
import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;
import 'package:react/react_client.dart';

var useStateTestFunctionComponent = react.registerFunctionComponent(UseStateTestComponent, displayName: 'useStateTest');

UseStateTestComponent(Map props) {
  final count = useState(0);

  return react.div({}, [
    count.value,
    react.button({'onClick': (_) => count.set(0)}, ['Reset']),
    react.button({
      'onClick': (_) => count.setWithUpdater((prev) => prev + 1),
    }, [
      '+'
    ]),
  ]);
}

var useReducerTestFunctionComponent =
    react.registerFunctionComponent(UseReducerTestComponent, displayName: 'useReducerTest');

Map initializeCount(int initialValue) {
  return {'count': initialValue};
}

Map reducer(Map state, Map action) {
  switch (action['type']) {
    case 'increment':
      return {...state, 'count': state['count'] + 1};
    case 'decrement':
      return {...state, 'count': state['count'] - 1};
    case 'reset':
      return initializeCount(action['payload']);
    default:
      return state;
  }
}

UseReducerTestComponent(Map props) {
  final state = useReducerLazy(reducer, props['initialCount'], initializeCount);

  return react.Fragment({}, [
    state.state['count'],
    react.button({
      'onClick': (_) => state.dispatch({'type': 'increment'})
    }, [
      '+'
    ]),
    react.button({
      'onClick': (_) => state.dispatch({'type': 'decrement'})
    }, [
      '-'
    ]),
    react.button({
      'onClick': (_) => state.dispatch({
            'type': 'reset',
            'payload': props['initialCount'],
          })
    }, [
      'reset'
    ]),
  ]);
}

void main() {
  setClientConfiguration();

  render() {
    react_dom.render(
        react.Fragment({}, [
          react.h1({'key': 'functionComponentTestLabel'}, ['Function Component Tests']),
          react.h2({'key': 'useStateTestLabel'}, ['useState Hook Test']),
          useStateTestFunctionComponent({
            'key': 'useStateTest',
          }, []),
          react.br({}),
          react.h2({'key': 'useReducerTestLabel'}, ['useReducer Hook Test']),
          useReducerTestFunctionComponent({
            'key': 'useReducerTest',
            'initialCount': 10,
          }, []),
        ]),
        querySelector('#content'));
  }

  render();
}
