import 'package:dust_component/component.dart';
import 'package:dust_component/stateful_component.dart';
import 'package:dust_component/state.dart';
import 'package:dust_component/vnode.dart';
import 'dart:math'; // For random keys initially
import 'dart:async'; // For Future.delayed
import 'dart:js_interop'; // Needed for JSAny

// Simple Todo Item model
class TodoItem {
  final int id;
  String text;
  bool completed;

  TodoItem({required this.id, required this.text, this.completed = false});
}

// TodoListComponent State
class _TodoListState extends State<TodoListComponent> {
  List<TodoItem> _items = [];
  int _nextId = 0;
  final Random _random = Random(); // For shuffling
  Timer? _testTimer;

  @override
  void initState() {
    super.initState();
    // Add some initial items
    _addItem('Learn Dust');
    _addItem('Implement Keyed Diffing');
    _addItem('Test Keyed Diffing');

    // Schedule automatic state changes for testing (Now commented out)
    // _scheduleTestUpdates();
  }

  @override
  void dispose() {
    _testTimer?.cancel(); // Cancel timer when component is disposed
    super.dispose();
  }

  void _scheduleTestUpdates() {
    int step = 0;
    _testTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      step++;
      print("--- Automatic Test Update: Step $step ---");
      switch (step) {
        case 1:
          print("Triggering Shuffle...");
          _shuffleItems();
          break;
        case 2:
          print("Triggering Add...");
          _addItem("New Item Added @ ${DateTime.now().second}s");
          break;
        case 3:
          if (_items.isNotEmpty) {
            final idToRemove = _items[_random.nextInt(_items.length)].id;
            print("Triggering Remove (ID: $idToRemove)...");
            _removeItem(idToRemove);
          } else {
            print("Skipping Remove (list empty)");
          }
          break;
        case 4:
          print("Triggering Shuffle again...");
          _shuffleItems();
          break;
        case 5:
          if (_items.isNotEmpty) {
            final idToToggle = _items[_random.nextInt(_items.length)].id;
            print("Triggering Toggle (ID: $idToToggle)...");
            _toggleItem(idToToggle);
          } else {
            print("Skipping Toggle (list empty)");
          }
          break;
        default:
          print("Test sequence finished.");
          timer.cancel();
      }
    });
  }

  void _addItem(String text) {
    setState(() {
      _items.add(TodoItem(id: _nextId++, text: text));
      print("Items after add: ${_items.map((i) => i.id).toList()}");
    });
  }

  void _removeItem(int id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
      print("Items after remove ($id): ${_items.map((i) => i.id).toList()}");
    });
  }

  void _toggleItem(int id) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index].completed = !_items[index].completed;
        print("Toggled item $id completion to ${_items[index].completed}");
      }
    });
  }

  void _shuffleItems() {
    setState(() {
      _items.shuffle(_random);
      print("Items after shuffle: ${_items.map((i) => i.id).toList()}");
    });
  }

  @override
  VNode build() {
    print("Building TodoList VNode tree...");
    return VNode.element('div', children: [
      VNode.element('h1',
          children: [VNode.text('Dust Todo List (Keyed Diffing Test)')]),
      VNode.element('ul',
          children: _items.map((item) {
            // *** Use item.id as the key ***
            print("Creating VNode for item ID: ${item.id}, text: ${item.text}");
            return VNode.element('li',
                key: item.id, // Key is crucial here!
                attributes: {
                  'style': item.completed
                      ? 'text-decoration: line-through; color: grey;'
                      : '',
                  'data-id': '${item.id}' // Add data-id for easier inspection
                },
                children: [
                  VNode.text('${item.text} (ID: ${item.id}) '),
                  // Buttons are placeholders for now, event handling not implemented
                  VNode.element('button',
                      // Remove 'disabled' attribute
                      listeners: {
                        'click': (JSAny event) => _toggleItem(
                            item.id) // Add click listener with JSAny
                      },
                      children: [
                        VNode.text('Toggle')
                      ]),
                  VNode.element('button',
                      // Remove 'disabled' attribute
                      listeners: {
                        'click': (JSAny event) => _removeItem(
                            item.id) // Add click listener with JSAny
                      },
                      children: [
                        VNode.text('Remove')
                      ])
                ]);
          }).toList()),
      // Buttons are placeholders for now, event handling not implemented
      VNode.element('button',
          // Remove 'disabled' attribute
          listeners: {
            'click': (JSAny event) => _addItem(
                'New Item Added Manually') // Add click listener with JSAny
          },
          children: [
            VNode.text('Add Item')
          ]),
      VNode.element('button',
          // Remove 'disabled' attribute
          listeners: {
            'click': (JSAny event) =>
                _shuffleItems() // Add click listener with JSAny
          },
          children: [
            VNode.text('Shuffle Items')
          ])
    ]);
    // NOTE: Buttons don't work yet as event handling is not implemented.
    // Automatic updates are scheduled in initState for testing.
  }
}

// TodoListComponent Widget
class TodoListComponent extends StatefulWidget {
  @override
  State<TodoListComponent> createState() => _TodoListState();
}
