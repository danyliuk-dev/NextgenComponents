# NgCheckBox — Флажок

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Редактирует независимое логическое состояние.

## Поведение и практические правила

Состояние хранит родитель: обязательно сохраняйте новое значение из callback. Во Flutter onChanged: null отключает управление; в Blazor используйте Disabled. Label должен объяснять, что именно включается. Поддерживается только true/false, третьего состояния нет. Для группы взаимоисключающих вариантов используйте NgRadioGroup.

## Blazor: рабочий пример

```razor
<NgCheckBox Label="Уведомления" @bind-Value="enabled"/>
@code { private bool enabled=true; }
```

## Flutter: рабочий пример

```dart
bool enabled = true;
Widget build(BuildContext context) => NgCheckBox(label: 'Уведомления',
  value: enabled, onChanged: (v) => setState(() => enabled = v));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Label` | `string` | "" | Подпись элемента или доступное имя. |
| `Value` | `bool` | false | Текущее значение; тип и правила описаны выше. |
| `ValueChanged` | `EventCallback<bool>` | не задан | Новое значение для родителя; сохраните его в модели. |
| `ValueExpression` | `System.Linq.Expressions.Expression<Func<bool>>?` | не задан | Выражение поля модели для валидации. @bind-Value создаёт автоматически; при ручных Value/ValueChanged передайте явно, даже вне формы. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |
| `AdditionalAttributes` | `Dictionary<string,object>?` | не задан | Дополнительные HTML/ARIA атрибуты; не используйте для обхода проверок модели. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `label` | `String` | Подпись элемента или доступное имя. |
| `value` | `bool` | Текущее значение; тип и правила описаны выше. |
| `onChanged` | `ValueChanged<bool>?` | Новое значение для родителя; обновите состояние через setState. |

```dart
const NgCheckBox({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgCheckBox.razor)
- [Flutter](../../packages/nextgen_components/lib/src/components.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
