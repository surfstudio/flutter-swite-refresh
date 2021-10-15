// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_refresh/swipe_refresh.dart';

import 'test_utils.dart';

void main() {
  late StreamController<SwipeRefreshState> _controller;
  late Stream<SwipeRefreshState> stream;

  setUp(() {
    _controller = StreamController<SwipeRefreshState>.broadcast();
    stream = _controller.stream;
  });

  tearDown(() async {
    await _controller.close();
  });

  Future<void> _onRefresh() async {
    _controller.sink.add(SwipeRefreshState.loading);

    await Future<void>.delayed(const Duration(seconds: 3));

    _controller.sink.add(SwipeRefreshState.hidden);
  }

  final listColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.amber,
  ];

  testWidgets(
    'SwipeRefresh.material widget with children as argument does not break',
    (tester) async {
      final materialSwipeRefresh = makeTestableWidget(
        SwipeRefresh.material(
          stateStream: stream,
          onRefresh: _onRefresh,
          children: listColors
              .map(
                (e) => Container(
                  color: e,
                  height: 100,
                ),
              )
              .toList(),
        ),
      );

      await tester.pumpWidget(materialSwipeRefresh);

      expect(() => materialSwipeRefresh, returnsNormally);

      expect(find.byType(Container), findsNWidgets(4));

      expect(find.byType(MaterialSwipeRefresh), findsOneWidget);
    },
  );

  testWidgets(
    'When drag down enough, the refresh should start with the correct statuses',
    (tester) async {
      final events = <SwipeRefreshState>[];

      stream.listen(events.add);

      final materialSwipeRefresh = makeTestableWidget(
        SwipeRefresh.material(
          stateStream: stream,
          onRefresh: _onRefresh,
          children: listColors
              .map(
                (e) => Container(
                  color: e,
                  height: 100,
                ),
              )
              .toList(),
        ),
      );

      await tester.pumpWidget(materialSwipeRefresh);

      await tester.drag(
        find.byType(SwipeRefresh),
        const Offset(0, 300),
        touchSlopY: 0,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(events, equals([SwipeRefreshState.loading]));

      await tester.pump(const Duration(seconds: 3));

      expect(events.last, equals(SwipeRefreshState.hidden));
    },
  );

  testWidgets(
    'When drag down is not enough to trigger an update the update should not be',
    (tester) async {
      final events = <SwipeRefreshState>[];

      stream.listen(events.add);

      final materialSwipeRefresh = makeTestableWidget(
        SwipeRefresh.material(
          stateStream: stream,
          onRefresh: _onRefresh,
          children: listColors
              .map(
                (e) => Container(
                  color: e,
                  height: 100,
                ),
              )
              .toList(),
        ),
      );
      await tester.pumpWidget(materialSwipeRefresh);

      expect(events, isEmpty);

      await tester.drag(
        find.byType(SwipeRefresh),
        const Offset(0, 50),
        touchSlopY: 0,
      );

      await tester.pump();

      expect(events, isEmpty);
    },
  );
}
