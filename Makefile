.PHONY: setup
setup:
	flutter clean
	flutter pub get

br:
	flutter pub run build_runner build

brd:
	flutter packages pub run build_runner build --delete-conflicting-outputs

TEST_PATH = test/model_test.dart
WIDGET_TEST_PATH = test/widget/task_item_test.dart

run_test:
	flutter test $(TEST_PATH)

runw_test:
	flutter test $(WIDGET_TEST_PATH)