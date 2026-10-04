# Edición de contenido

El sitio separa el contenido editable de la presentación, siguiendo el modelo de
[Megajuegos](https://github.com/megajuegos/megajuegos.github.io). Jekyll lee una sola
colección, `_contenido`, y las plantillas conservan el diseño actual.

## Dónde editar

| Contenido | Archivos |
| --- | --- |
| Portada en castellano | `_contenido/home_es/` |
| Portada en inglés | `_contenido/home_en/` |
| Artículos de prensa | `_contenido/media/` |
| Links de la charla | `_contenido/paginas/links.md` |

Cada archivo tiene dos partes:

- El encabezado YAML entre `---` contiene títulos, imágenes, botones y otros datos.
- El cuerpo contiene los párrafos, links y listas en Markdown.

Las traducciones se editan por separado. Los archivos con `kind: home_media` y
`kind: home_game` sólo necesitan el encabezado: representan un título de sección
o un par de imágenes.

## Texto y links

Separá los párrafos con una línea en blanco. Para un salto de línea dentro de un
párrafo, dejá **dos espacios al final de la línea**. Los links y listas se escriben
con Markdown:

```markdown
Podés encontrar el código en [GitHub](https://github.com/ventilastation/vsdk).

- Primer elemento
- Segundo elemento
```

`heading` es el título del bloque. Para conservar un título de varias líneas,
usá una lista en YAML; una última línea vacía conserva el salto final:

```yaml
heading:
  - Un chip ESP32 y 107 leds,
  - girando a 600RPM
```

Los botones del banner se editan en `actions`, con un `label` y un `url` por botón.
El contacto usa `contact_label` y `contact_url`. Las imágenes se eligen con `image`
y `image_alt`; los juegos también tienen `controls_image`, `controls_alt` y
`controls_width`. Conservá los prefijos actuales de las imágenes: `images/` para
la portada en castellano y `/images/` para la portada en inglés.

## Orden y nuevos elementos

Los destacados (`kind: home_spotlight`), juegos (`kind: home_game`) y artículos
(`kind: media`) se ordenan por el campo numérico `order`, no por el nombre del
archivo. Para agregar uno, copiá un archivo del mismo tipo y elegí un `order`
distinto. En las portadas, `lang: es` o `lang: en` determina dónde aparece.

Los bloques únicos se seleccionan por `kind`: `home_banner`, `home_intro`,
`home_play`, `home_media`, `home_develop`, `home_build` y `home_contact`. Conservá
un solo archivo de cada tipo por idioma. `section_id` mantiene los destinos de
los botones y enlaces de la página.

## Presentación y configuración

`_includes/home.html` compone las portadas y define su orden. `_includes/home/`
contiene la estructura HTML de cada bloque. `_includes/media.html` y
`_includes/talk-links.html` presentan los artículos y links. Los estilos siguen
en `_sass/` y `css/`, y el marco de las páginas en `_layouts/`.

Los puntos de entrada `index.html`, `en/index.html` y `links.html` mantienen las
URLs `/`, `/en/` y `/links.html`. El título y la descripción para metadatos,
redes sociales y datos generales siguen en `_config.yml`. La colección tiene
`output: false`: sus archivos no se publican como páginas independientes.

`generic.html` y `elements.html` son ejemplos del tema original. El emulador y
sus archivos generados tienen su propio proceso de publicación.

## Vista previa

Con Ruby y Bundler instalados:

```sh
bundle install
bundle exec jekyll serve --destination .tmp/content-preview
```

Abrí `http://localhost:4000/`, `/en/` y `/links.html` para revisar los cambios.
Para generar únicamente el sitio:

```sh
bundle exec jekyll build --destination .tmp/content-preview
```

La carpeta `.tmp` está ignorada por Git. No hace falta editar `_site/` ni ejecutar
`make publish` para cambiar o previsualizar contenido. La publicación completa,
incluido el emulador, sigue el procedimiento de `DEPLOY.md`.
