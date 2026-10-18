# NgButton — Кнопка

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Запускает действие пользователя: сохранить, открыть окно, применить фильтр.

## Поведение и практические правила

Primary выделяет основное действие. Blazor: Disabled блокирует кнопку; Type="submit" отправляет родительскую форму. Flutter: onPressed: null отключает кнопку. Для асинхронного сохранения храните флаг busy у родителя и отключайте повторное нажатие. Компонент сам не отправляет HTTP-запросы.

## Blazor: рабочий пример

```razor
<NgButton Primary OnClick="()=>count++">Нажато @count раз</NgButton>
@code { private int count; }
```

## Flutter: рабочий пример

```dart
int count = 0;
Widget build(BuildContext context) => NgButton(primary: true,
  onPressed: () => setState(() => count++), child: Text('Нажато $count раз'));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `ChildContent` | `RenderFragment?` | не задан | Содержимое Razor-компонента. |
| `Primary` | `bool` | false | Выделяет основное действие цветом темы. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |
| `Type` | `string` | "button" | HTML-тип кнопки: button или submit. |
| `OnClick` | `EventCallback<MouseEventArgs>` | не задан | Событие нажатия. |
| `AdditionalAttributes` | `Dictionary<string,object>?` | не задан | Дополнительные HTML/ARIA атрибуты; не используйте для обхода проверок модели. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `child` | `Widget` | Дочерний Flutter-виджет. |
| `onPressed` | `VoidCallback?` | Обработчик нажатия; null отключает Flutter-кнопку. |
| `primary` | `bool` | Выделяет основное действие цветом темы. |

```dart
const NgButton({
    super.key,
    required this.child,
    this.onPressed,
    this.primary = false,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgButton.razor)
- [Flutter](../../packages/nextgen_components/lib/src/components.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
