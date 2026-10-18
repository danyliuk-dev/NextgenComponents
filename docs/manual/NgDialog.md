# NgDialog — Модальное окно

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Показывает отдельную задачу или редактор поверх страницы.

## Поведение и практические правила

Blazor: управляйте Open через @bind-Open, чтобы закрытие обновляло родителя. Flutter: NgDialog.show<T> возвращает Future<T?>, результат задаётся Navigator.pop(context, result); null соответствует закрытию без результата. Редактируйте отдельную копию данных и переносите изменения только при Save. Отмена не должна менять исходную запись. Не создавайте несколько вложенных несогласованных модальных задач.

## Blazor: рабочий пример

```razor
<NgButton OnClick="()=>open=true">Открыть</NgButton>
<NgDialog Title="Подтверждение" @bind-Open="open"><ChildContent>Продолжить?</ChildContent><Actions><NgButton OnClick="()=>open=false">Закрыть</NgButton></Actions></NgDialog>
@code { private bool open; }
```

## Flutter: рабочий пример

```dart
Widget build(BuildContext context) => NgButton(child: const Text('Открыть'),
  onPressed: () => NgDialog.show<void>(context, title: 'Подтверждение',
    child: const Text('Продолжить?'), actions: [TextButton(
      onPressed: () => Navigator.of(context).pop(), child: const Text('Закрыть'))]));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Open` | `bool` | false | Открыто ли окно. |
| `OpenChanged` | `EventCallback<bool>` | не задан | Сообщает родителю о закрытии/открытии. |
| `Title` | `string` | "Dialog" | Заголовок блока или окна. |
| `ChildContent` | `RenderFragment?` | не задан | Содержимое Razor-компонента. |
| `Actions` | `RenderFragment?` | не задан | Кнопки/действия окна. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `title` | `String` | Заголовок блока или окна. |
| `child` | `Widget` | Дочерний Flutter-виджет. |
| `actions` | `List<Widget>` | Кнопки/действия окна. |

```dart
const NgDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgDialog.razor)
- [Flutter](../../packages/nextgen_components/lib/src/components.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
