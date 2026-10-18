# NgPager — Страницы данных

[Оглавление](README.md) · [Подключение](getting-started.md) · [Модели](models.md)

## Когда использовать

Управляет номером страницы и размером порции; сами записи фильтрует приложение или NgDataGrid.

## Поведение и практические правила

Нумерация страниц начинается с 1. Total — число записей после фильтра, а не размер текущей страницы. Сначала фильтруйте/сортируйте данные, затем выделяйте страницу. После сокращения набора ограничьте page через NgDataOperations.ClampPage/clampPage. Не передавайте неположительный pageSize; используйте значение из Sizes/sizes. Серверную загрузку по callback реализует приложение.

## Blazor: рабочий пример

```razor
<NgPager Total="items.Length" @bind-Page="page" @bind-PageSize="size"/>
@foreach(var item in items.Skip((page-1)*size).Take(size)){<p>@item</p>}
@code { private int page=1,size=5; private string[] items=Enumerable.Range(1,18).Select(i=>$"Строка {i}").ToArray(); }
```

## Flutter: рабочий пример

```dart
int page = 1, size = 5;
Widget build(BuildContext context) => NgPager(total: 18, page: page, pageSize: size,
  onPageChanged: (v) => setState(() => page = v),
  onPageSizeChanged: (v) => setState(() { size = v; page = 1; }));
```

## Параметры и события Blazor

Имена чувствительны к регистру. `?` в типе разрешает null. Параметры с `EditorRequired` отмечены как обязательные; остальные имеют значение по умолчанию CLR или инициализатор ниже.

| Параметр | Тип | По умолчанию / требование | Назначение |
|---|---|---|---|
| `Total` | `int` | 0 | Число записей после фильтрации. |
| `Page` | `int` | 1 | Текущая страница, начиная с 1. |
| `PageSize` | `int` | 10 | Положительное количество строк на странице. |
| `Sizes` | `IReadOnlyList<int>` | [5,10,25,50] | Доступные размеры страницы. |
| `Disabled` | `bool` | false | true запрещает действия пользователя. |
| `Label` | `string` | "Pagination" | Подпись элемента или доступное имя. |
| `PageChanged` | `EventCallback<int>` | не задан | Запрос изменить номер страницы. |
| `PageSizeChanged` | `EventCallback<int>` | не задан | Запрос изменить размер страницы. |

## Параметры и события Flutter

`required` в конструкторе означает обязательный аргумент, даже если его тип допускает null. `key` — стандартный Flutter Key. Значения по умолчанию приведены в точной сигнатуре ниже.

| Аргумент | Тип | Назначение |
|---|---|---|
| `total` | `int` | Число записей после фильтрации. |
| `page` | `int` | Текущая страница, начиная с 1. |
| `pageSize` | `int` | Положительное количество строк на странице. |
| `sizes` | `List<int>` | Доступные размеры страницы. |
| `onPageChanged` | `ValueChanged<int>` | Запрос изменить номер страницы. |
| `onPageSizeChanged` | `ValueChanged<int>` | Изменение размера страницы; обычно также сбрасывают page в 1. |
| `enabled` | `bool` | false запрещает действия пользователя. |

```dart
const NgPager({
    super.key,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.sizes = const [5, 10, 25, 50],
    this.enabled = true,
  });
```

## Интеграция и диагностика

Если интерфейс не обновляется, проверьте, сохраняет ли родитель результат callback и передаёт ли новое значение обратно. Для Blazor нужен интерактивный render mode; для Flutter — setState или используемый менеджер состояния. Данные формы отправляйте только после её успешной валидации.

Проверяйте понятную подпись, пустое состояние, недоступность и размер контейнера. Клавиатурные возможности не означают полной сертификации screen reader. Сейчас проверяется Web в Chrome; нативные мобильные платформы будут проверяться отдельно.

## Исходники и полный сценарий

- [Blazor](../../src/NextgenComponents.Blazor/NgPager.razor)
- [Flutter](../../packages/nextgen_components/lib/src/data.dart)
- [Галереи и запуск](../../README.md#run)
- [Матрица возможностей](../catalog.md)

Версия параметров сгенерирована из текущего исходного кода. Примеры и правила сопровождаются отдельно в `scripts/manual_content.py`; после изменения API выполните `python3 scripts/generate_manual.py`.
