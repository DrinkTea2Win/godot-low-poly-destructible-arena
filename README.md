# Low-Poly Destructible Arena — Godot 4.7

Процедурная стилизованная арена **500×500 м**: фасеточный HeightMap-ландшафт, северный лес из острых крон, южные CSG-руины, скальные гряды и мосты, центральный кратер, разрушаемый декор. Внешние модели и текстуры не требуются.

## Быстрый запуск

1. Установите **Godot 4.7**, стандартную сборку с .NET не требуется.
2. **Import → Browse → `project.godot` → Import & Edit**.
3. Откройте `Scenes/Main.tscn`, нажмите **F6** или запустите проект через **F5**.
4. Дождитесь генерации сцены. Весь контент строится один раз в `_ready()`, без ежекадровой генерации.

**Управление:** `Tab` — обзорная камера/игрок; `WASD` — движение; мышь — обзор игроком; `ЛКМ` — удар/разрушение; `Space` — прыжок; `Shift` — ускорение обзорной камеры; `Q/E` — вниз/вверх; колесо мыши — FOV обзорной камеры; `Esc` — освободить курсор.

Для полноэкранной проверки используйте **Forward+**. В Mobile сохраните Directional Shadows и Glow, но проверьте SSAO на целевом GPU. Compatibility не поддерживает все заданные эффекты окружения.

## Структура проекта

```text
godot-low-poly-destructible-arena/
├── project.godot                  # Forward+, главная сцена, слои физики
├── Scenes/
│   ├── Main.tscn                  # Environment, свет, арена, камеры, игрок
│   ├── ObserverCamera.tscn        # Y=200, X=-60°, перспектива, FOV=70
│   └── DemoPlayer.tscn            # CharacterBody3D для проверки разрушений
├── Scripts/
│   ├── Main.gd                    # Ввод и переключение камер
│   ├── ArenaBuilder.gd            # Общая генерация и разрушаемый декор
│   ├── TerrainBuilder.gd          # Меш 500×500 + HeightMapShape3D
│   ├── ArchitectureBuilder.gd     # Центр, руины, гряды, мосты, кристаллы
│   ├── ScatterBuilder.gd          # MultiMesh: деревья, камни, кусты
│   ├── MeshFactory.gd             # Только гранёные Box/Cylinder/CSG-формы
│   ├── Destructible.gd            # Урон, импакт, GPUParticles3D, очистка
│   ├── DemoPlayer.gd              # Движение, прыжок, raycast-удар
│   └── ObserverCamera.gd          # Полёт обзорной камеры
├── Materials/
│   ├── Palette.gd                 # Единая палитра и emissive-материалы
│   └── GroundTriplanar.tres       # NoiseTexture2D + world triplanar
└── Assets/
    └── README.md                  # Место для необязательных Kenney-ассетов
```

## Стилистика и палитра

| Назначение | Цвет |
|---|---|
| Земля | `#3B3631` |
| Камень | `#5E6366` |
| Изумрудная листва | `#2A5C38` |
| Оранжевые акценты крон | `#C76B22` |
| Магический циан | `#00E5FF` |
| Неоновый фиолетовый | `#9D00FF` |

`SphereMesh` нигде не используется. Стволы — 8-гранные `CylinderMesh`; кроны — трёхгранные острые конусы; камни — пятигранные усечённые цилиндры; кусты — `PrismMesh`; декор и руины — Box/CSG с жёсткими углами.

## Ландшафт и зонирование

- Сетка: **100×100 ячеек**, шаг **5 м**, размеры **500×500 м**. Меш неиндексированный, поэтому нормали треугольников остаются фасеточными.
- Коллизия: `HeightMapShape3D`, **101×101 samples**, масштаб X/Z = 5 м. Высоты визуального меша и коллизии вычисляет одна функция `TerrainBuilder.height_at()`.
- Высоты: широкие синусоиды + детали + центральный кратер с кольцевым валом + восточный/западный хребты. Карта не плоская.
- Земля: `StandardMaterial3D`, `uv1_triplanar=true`, `uv1_world_triplanar=true`, масштаб UV `0.08`. NoiseTexture не растягивается на склонах.
- Центр: кратер, подиум, 12 целых/сломанных колонн, 4 светящихся кристалла.
- Север: плотный лес; юг: 15 руинированных домов и фрагменты стен; восток/запад: скальные гряды и мосты.

## MultiMesh и производительность

`ScatterBuilder.gd` создаёт до **2200 деревьев**. Для них используются три `MultiMeshInstance3D`: стволы, нижние изумрудные кроны и верхние оранжевые кроны. Это **3 draw call на 2200 деревьев**, а не 6600 отдельных нодов. Камни и кусты имеют собственные MultiMesh.

Почему такая структура:

1. Один MultiMesh хранит один Mesh и один Material. Ствол и крона разделены, чтобы не создавать тысячи нодов и сохранить разные цвета.
2. `RandomNumberGenerator` имеет фиксированный seed `470500`: раскладка воспроизводима.
3. Лес не создаёт 2200 физических тел. Для навигации добавляйте коллизии только около игровых маршрутов или используйте отдельный low-res collision layer.
4. Directional shadow distance ограничена **220 м**; тени не рассчитываются на всю карту.
5. Для слабых GPU уменьшайте лимит 2200, количество камней/кустов и размер Shadow Atlas. Не заменяйте MultiMesh отдельными MeshInstance3D.
6. Для большого открытого мира следующий шаг — чанки 50×50 м и HLOD/visibility ranges. На одной арене 500×500 м текущий вариант проще и дешевле.

### Как собрать лес вручную через редактор

Проект уже делает это кодом. Для своей сцены:

1. Создайте `MultiMeshInstance3D`, назначьте `MultiMesh`.
2. В `MultiMesh`: **Transform Format = 3D**, в `Mesh` задайте 8-гранный Cylinder для ствола.
3. Установите `Instance Count`, для каждого индекса задайте `set_instance_transform(i, Transform3D(basis, position))`.
4. Повторите для кроны отдельным MultiMesh с трёхгранным конусом (`top_radius=0`).
5. Назначьте материал в `MultiMeshInstance3D.material_override`.

## Разрушаемость

`Destructible.gd` наследует `RigidBody3D`:

- `apply_damage(amount, hit_position)` уменьшает HP и вызывает разрушение при нуле.
- `contact_monitor` + `max_contacts_reported` отслеживают удары; скорость до контакта сохраняется в `_last_speed`.
- Импакт ниже `impact_threshold` игнорируется, остаток скорости умножается на `impact_damage_scale`.
- При разрушении создаётся one-shot `GPUParticles3D`: 28 гранёных Box-осколков, гравитация, случайный разброс и вращение.
- Осколки автоматически удаляются через **2 секунды**; исходное тело удаляется через `queue_free()`.
- Игрок бьёт raycast до 7 м. Слои: World = 1, Destructibles = 2, Player = 3 (бит 4).

Вызов из другого оружия:

```gdscript
if hit.collider is Destructible:
    hit.collider.apply_damage(50.0, hit.position)
```

## Точные настройки WorldEnvironment

Они уже сохранены в `Scenes/Main.tscn`:

- **Background:** Sky; `ProceduralSkyMaterial`.
- **Sky Top:** `#1A2938` (RGB 0.10/0.16/0.22); **Horizon:** `#85969C` приблизительно (0.52/0.59/0.61).
- **Ambient Light:** Color, RGB `(0.55, 0.64, 0.72)`, Energy `0.55`.
- **Tonemap:** Filmic, Exposure `1.0`.
- **SSAO:** Enabled, Radius `2.0`, Intensity `2.0`, Power `1.5`.
- **Glow:** Enabled, Intensity `0.8`, Strength `1.1`, Bloom `0.08`.
- **Fog:** Enabled, Color `(0.44, 0.50, 0.54)`, Energy `0.65`, Density `0.0015`, Sky Affect `0.2`.
- **DirectionalLight3D:** Rotation `(-48°, -32°, 0)`, Energy `1.25`, цвет `(1.0, 0.88, 0.72)`, тени включены, Max Distance `220`.

Неон получает свечение через `emission_enabled=true` и `emission_energy_multiplier=3.0`. Не ставьте OmniLight на каждое дерево: локальный свет есть только у четырёх центральных кристаллов.

## Настройка и расширение

- Seed и автогенерация: экспорты `world_seed`, `generate_on_ready` у ноды `Arena`.
- Плотность леса: лимит в `ScatterBuilder.build()`.
- Рельеф: меняйте только `height_at()` — меш и коллизия останутся синхронными.
- Здоровье/материал осколков: параметры при создании в `ArenaBuilder._spawn_destructibles()`.
- Готовые модели: при необходимости Kenney **Nature Kit / Castle Kit**, но текущая версия полностью автономна.
