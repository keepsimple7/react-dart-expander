@JS()
library js_function_test;

import 'package:js/js.dart';
import 'package:react/react_client/js_interop_helpers.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:test/test.dart';

void main() {
  group('group', () {
    group('getProperty', () {
      test('is function that does not throw upon initialization', () {
        expect(() => getProperty, const isInstanceOf<Function>());
      });

      test('gets the specified property on an object', () {
        var jsObj = new TestJsObject(foo: 'bar');
        expect(jsObj.foo, equals('bar'), reason: 'test setup sanity-check');

        expect(getProperty(jsObj, 'foo'), equals('bar'));
      });
    });

    group('setProperty', () {
      test('is function that does not throw upon initialization', () {
        expect(() => getProperty, const isInstanceOf<Function>());
      });

      test('sets the specified property on an object', () {
        var jsObj = new TestJsObject();
        expect(jsObj.foo, isNull, reason: 'test setup sanity-check');

        expect(setProperty(jsObj, 'foo', 'bar'), equals('bar'),
            reason: 'should return the result of the assignment expression');

        expect(jsObj.foo, equals('bar'));
      });
    });

    group('markChildValidated', () {
      test('is function that does not throw when called', () {
        expect(() => markChildValidated(new EmptyObject()), returnsNormally);
      });
    });

    group('createReactDartComponentClassConfig', () {
      test('is function that does not throw when called', () {
        expect(() => createReactDartComponentClassConfig(null, null), returnsNormally);
      });
    });
  });
}

@JS()
@anonymous
class TestJsObject {
  external factory TestJsObject({foo});

  external get foo;
}
