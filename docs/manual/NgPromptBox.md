# NgPromptBox — Поле запроса

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Многострочное поле для запроса или сообщения с кнопками Send/Cancel. Подходит для собственного чата, AI-формы или поиска с асинхронной обработкой.

## Поведение и практические правила

Value/value — текст, ValueChanged/onChanged — изменение при вводе. Сохраняйте новое значение у родителя, как в примере. Для внешней замены передайте другое значение. Поле имеет локальный черновик; повторная передача того же внешнего значения не сбрасывает его. Label/label задаёт доступное имя, Placeholder/placeholder — подсказку внутри пустого поля.

MaxLength/maxLength — 1–8000 UTF-16 code units, по умолчанию 8000. Emoji может занимать две единицы; обе платформы используют одинаковую границу. Слишком длинный внешний Value/value отклоняется, ввод ограничивается в поле. Текст не превращается в HTML. Enter добавляет новую строку; Tab переводит фокус на кнопку, Enter/Space нажимает её. Автоматической отправки по Enter нет. Blazor поле начинается с трёх строк и меняется по высоте мышью; Flutter — 3–6 строк со внутренней прокруткой.

OnSubmit/onSubmit получает текст с обрезанными пробелами по краям. Пустой/пробельный запрос и отсутствие обработчика отключают Send. Компонент не очищает поле после отправки. Busy/busy блокирует редактирование и заменяет Send на Cancel; OnCancel/onCancel должен отменять работу приложения. ReadOnly/readOnly запрещает ввод и отправку; Cancel остаётся доступным для уже выполняемой работы. Без обработчика отмены Cancel отключён.

PromptBox сам не выполняет HTTP-запрос, не знает состояния генерации и не гарантирует отмену провайдера. Родитель должен сразу установить Busy/busy перед первым await, обработать ошибку и убрать busy в finally. Пример показывает игнорирование запоздалого результата по номеру запроса; транспортную отмену нужно реализовать в адаптере. Для готового управления историей, отменой и ошибками используйте NgAIPrompt.

Текущий объём — многострочный текст, счётчик, отправка/отмена, readonly и внешнее обновление. Вложения, speech-to-text, режим Auto/SingleLine, пользовательские adornments и streaming пока не реализованы. Проверен Web; мобильные платформы отдельно.

## Blazor: рабочий пример

```razor
<NgPromptBox Label="Запрос" @bind-Value="prompt" Busy="busy" OnSubmit="Submit" OnCancel="Cancel"/>
<p>@result</p>
@code {
 private string prompt="",result=""; private bool busy; private int revision;
 private async Task Submit(string text) {
  var request=++revision; busy=true;
  await Task.Delay(700); // Локальный пример; замените обработчиком приложения.
  if(request!=revision)return;
  result=$"Получен запрос: {text}"; busy=false;
 }
 private void Cancel(){revision++;busy=false;result="Отменено";}
}
```

## Flutter: рабочий пример

```dart
String prompt = '', result = '';
bool busy = false;
int revision = 0;
Future<void> submit(String text) async {
  final request = ++revision;
  setState(() => busy = true);
  await Future<void>.delayed(const Duration(milliseconds: 700));
  if (!mounted || request != revision) return;
  setState(() { result = 'Получен запрос: $text'; busy = false; });
}
Widget build(BuildContext context) => NgPromptBox(label: 'Запрос', value: prompt,
  onChanged: (v) => setState(() => prompt = v), busy: busy,
  onSubmit: submit,
  onCancel: () => setState(() { revision++; busy = false; result = 'Отменено'; }));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Label` | `string` | "Prompt" | Подпись элемента или доступное имя. |
| `Value` | `string` | "" | Текущее значение; тип и правила описаны выше. |
| `ValueChanged` | `EventCallback<string>` | не задан | Новое значение для родителя; сохраните его в модели. |
| `Placeholder` | `string` | "Describe what you need…" | Подсказка внутри пустого поля. |
| `MaxLength` | `int` | 8000 | Максимальная длина текста. |
| `Busy` | `bool` | false | Смотрите поведение и тип модели выше. |
| `ReadOnly` | `bool` | false | Запрещает изменение данных, сохраняя просмотр; точное поведение описано выше. |
| `OnSubmit` | `EventCallback<string>` | не задан | Смотрите поведение и тип модели выше. |
| `OnCancel` | `EventCallback` | не задан | Смотрите поведение и тип модели выше. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `value` | `String` | Текущее значение; тип и правила описаны выше. |
| `placeholder` | `String` | Подсказка внутри пустого поля. |
| `maxLength` | `int` | Максимальная длина текста. |
| `busy` | `bool` | Смотрите поведение и тип модели выше. |
| `readOnly` | `bool` | Запрещает изменение данных, сохраняя просмотр; точное поведение описано выше. |
| `onChanged` | `ValueChanged<String>?` | Новое значение для родителя; обновите состояние через setState. |
| `onSubmit` | `ValueChanged<String>?` | Смотрите поведение и тип модели выше. |
| `onCancel` | `VoidCallback?` | Смотрите поведение и тип модели выше. |

```dart
const NgPromptBox({
    super.key,
    this.label = 'Prompt',
    this.value = '',
    this.placeholder = 'Describe what you need…',
    this.maxLength = 8000,
    this.busy = false,
    this.readOnly = false,
    this.onChanged,
    this.onSubmit,
    this.onCancel,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgPromptBox.razor)
- [Flutter](../../packages/nextgen_components/lib/src/prompt.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
