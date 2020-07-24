@TestOn('browser')
library react.react_memo_test;

import 'dart:async';
import 'dart:developer';
import 'dart:html';
import 'dart:js_util';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:react/react_test_utils.dart' as rtu;
import 'package:test/test.dart';

main() {
  setClientConfiguration();

  Ref<_MemoTestWrapperComponent> memoTestWrapperComponentRef;
  Ref<Element> localCountDisplayRef;
  Ref<Element> valueMemoShouldIgnoreViaAreEqualDisplayRef;
  int childMemoRenderCount;

  void renderMemoTest({
    bool testAreEqual = false,
    String displayName,
  }) {
    expect(memoTestWrapperComponentRef, isNotNull, reason: 'test setup sanity check');
    expect(localCountDisplayRef, isNotNull, reason: 'test setup sanity check');
    expect(valueMemoShouldIgnoreViaAreEqualDisplayRef, isNotNull, reason: 'test setup sanity check');

    final customAreEqualFn = !testAreEqual
        ? null
        : (prevProps, nextProps) {
            return prevProps['localCount'] == nextProps['localCount'];
          };

    final MemoTest = react.memo((Map props) {
      childMemoRenderCount++;
      return react.div(
        {},
        react.p(
          {'ref': localCountDisplayRef},
          props['localCount'],
        ),
        react.p(
          {'ref': valueMemoShouldIgnoreViaAreEqualDisplayRef},
          props['valueMemoShouldIgnoreViaAreEqual'],
        ),
      );
    }, areEqual: customAreEqualFn, displayName: displayName);

    rtu.renderIntoDocument(MemoTestWrapper({
      'ref': memoTestWrapperComponentRef,
      'memoComponentFactory': MemoTest,
    }));

    expect(localCountDisplayRef.current, isNotNull, reason: 'test setup sanity check');
    expect(valueMemoShouldIgnoreViaAreEqualDisplayRef.current, isNotNull, reason: 'test setup sanity check');
    expect(memoTestWrapperComponentRef.current.redrawCount, 0, reason: 'test setup sanity check');
    expect(childMemoRenderCount, 1, reason: 'test setup sanity check');
    expect(memoTestWrapperComponentRef.current.state['localCount'], 0, reason: 'test setup sanity check');
    expect(memoTestWrapperComponentRef.current.state['valueMemoShouldIgnoreViaAreEqual'], 0,
        reason: 'test setup sanity check');
    expect(memoTestWrapperComponentRef.current.state['valueMemoShouldNotKnowAbout'], 0,
        reason: 'test setup sanity check');
  }

  group('memo', () {
    setUp(() {
      memoTestWrapperComponentRef = react.createRef<_MemoTestWrapperComponent>();
      localCountDisplayRef = react.createRef<Element>();
      valueMemoShouldIgnoreViaAreEqualDisplayRef = react.createRef<Element>();
      childMemoRenderCount = 0;
    });

    tearDown(() {
      memoTestWrapperComponentRef = null;
      localCountDisplayRef = null;
      valueMemoShouldIgnoreViaAreEqualDisplayRef = null;
    });

    group('renders its child component when props change', () {
      test('', () {
        renderMemoTest();

        memoTestWrapperComponentRef.current.increaseLocalCount();
        expect(memoTestWrapperComponentRef.current.state['localCount'], 1, reason: 'test setup sanity check');
        expect(memoTestWrapperComponentRef.current.redrawCount, 1, reason: 'test setup sanity check');

        expect(childMemoRenderCount, 2);
        expect(localCountDisplayRef.current.text, '1');

        memoTestWrapperComponentRef.current.increaseValueMemoShouldIgnoreViaAreEqual();
        expect(memoTestWrapperComponentRef.current.state['valueMemoShouldIgnoreViaAreEqual'], 1,
            reason: 'test setup sanity check');
        expect(memoTestWrapperComponentRef.current.redrawCount, 2, reason: 'test setup sanity check');

        expect(childMemoRenderCount, 3);
        expect(valueMemoShouldIgnoreViaAreEqualDisplayRef.current.text, '1');
      });

      test('unless the areEqual argument is set to a function that customizes when re-renders occur', () {
        renderMemoTest(testAreEqual: true);

        memoTestWrapperComponentRef.current.increaseValueMemoShouldIgnoreViaAreEqual();
        expect(memoTestWrapperComponentRef.current.state['valueMemoShouldIgnoreViaAreEqual'], 1,
            reason: 'test setup sanity check');
        expect(memoTestWrapperComponentRef.current.redrawCount, 1, reason: 'test setup sanity check');

        expect(childMemoRenderCount, 1);
        expect(valueMemoShouldIgnoreViaAreEqualDisplayRef.current.text, '0');
      });
    });

    test('does not re-render its child component when parent updates and props remain the same', () {
      renderMemoTest();

      memoTestWrapperComponentRef.current.increaseValueMemoShouldNotKnowAbout();
      expect(memoTestWrapperComponentRef.current.state['valueMemoShouldNotKnowAbout'], 1,
          reason: 'test setup sanity check');
      expect(memoTestWrapperComponentRef.current.redrawCount, 1, reason: 'test setup sanity check');

      expect(childMemoRenderCount, 1);
    });
  });
}

final MemoTestWrapper = react.registerComponent(() => _MemoTestWrapperComponent());

class _MemoTestWrapperComponent extends react.Component2 {
  int redrawCount = 0;

  get initialState => {
        'localCount': 0,
        'valueMemoShouldIgnoreViaAreEqual': 0,
        'valueMemoShouldNotKnowAbout': 0,
      };

  @override
  void componentDidUpdate(Map prevProps, Map prevState, [dynamic snapshot]) {
    redrawCount++;
  }

  void increaseLocalCount() {
    this.setState({'localCount': this.state['localCount'] + 1});
  }

  void increaseValueMemoShouldIgnoreViaAreEqual() {
    this.setState({'valueMemoShouldIgnoreViaAreEqual': this.state['valueMemoShouldIgnoreViaAreEqual'] + 1});
  }

  void increaseValueMemoShouldNotKnowAbout() {
    this.setState({'valueMemoShouldNotKnowAbout': this.state['valueMemoShouldNotKnowAbout'] + 1});
  }

  @override
  render() {
    return react.div(
      {},
      props['memoComponentFactory']({
        'localCount': this.state['localCount'],
        'valueMemoShouldIgnoreViaAreEqual': this.state['valueMemoShouldIgnoreViaAreEqual'],
      }),
    );
  }
}
