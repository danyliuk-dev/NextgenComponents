# NgTextBox — Однострочный текст

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Ввод имени, описания или заметок с передачей изменений в модель.

## Поведение и практические правила

Blazor обновляет Value при вводе. Для обязательного поля используйте Required в модели NgForm. Flutter использует controller либо initialValue, но не оба сразу; initialValue не предназначен для последующего внешнего сброса. Для сброса меняйте controller.text и освобождайте controller в dispose. validator работает внутри Form/NgForm; null означает отсутствие ошибки. HTML в тексте не интерпретируется.

## Blazor: рабочий пример

```razor
<NgTextBox Label="Описание" @bind-Value="text"/>
<p>@text</p>
@code { private string? text="Начальный текст"; }
```

## Flutter: рабочий пример

```dart
final text = TextEditingController(text: 'Начальный текст');
@override void dispose() { text.dispose(); super.dispose(); }
Widget build(BuildContext context) => NgTextBox(label: 'Описание',
  controller: text, validator: (v) => v == null || v.trim().isEmpty ? 'Введите текст' : null);
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Id` | `string` | "ng-" + Guid.NewGuid().ToString("N") | Уникальный HTML ID; по умолчанию генерируется. |
| `Label` | `string` | "" | Подпись элемента или доступное имя. |
| `Placeholder` | `string?` | не задан | Подсказка внутри пустого поля. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |
| `Value` | `string?` | значение модели | Текущее значение поля. |
| `ValueChanged` | `EventCallback<string?>` | — | Изменение значения. |
| `ValueExpression` | `Expression<Func<string?>>` | обязательно | Автоматически создаётся @bind-Value; при ручной привязке передайте явно. |
| `AdditionalAttributes` | словарь HTML-атрибутов | null | Дополнительные HTML/ARIA атрибуты поля. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `controller` | `TextEditingController?` | Контроллер текста. Не совмещайте с initialValue; dispose выполняет владелец. |
| `initialValue` | `String?` | Начальное значение, а не постоянно управляемое значение. |
| `onChanged` | `ValueChanged<String>?` | Новое значение для родителя; обновите состояние через setState. |
| `validator` | `FormFieldValidator<String>?` | Проверка поля: null при успехе, строка с ошибкой при отказе. |
| `enabled` | `bool` | false запрещает действия пользователя. |
| `placeholder` | `String?` | Подсказка внутри пустого поля. |

```dart
const NgTextBox({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.placeholder,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgTextBox.razor)
- [Flutter](../../packages/nextgen_components/lib/src/components.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
