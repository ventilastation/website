---
layout: landing
language_url: /en/
language_label: English
navigation:
  - href: "#que"
    label: ¿Qué es?
  - href: "#como"
    label: ¿Cómo jugar?
  - href: "#juegos"
    label: Hacé un juego
  - href: "#hardware"
    label: Armate una
---

{% include home/language-switcher.html url=page.language_url label=page.language_label %}
{% include home/background-video.html %}

{% capture hero %}
## {{ site.title }}

{{ site.description }}
{% endcapture %}
{% include home/hero.html content=hero navigation=page.navigation more_href="#que" more_label="Más info" %}

{% capture about %}
## ¿Qué es Ventilastation?

Es una consola open source, para poder hacer y jugar videojuegos circulares. Íntegramente creada y fabricada en Argentina.

Es la sucesora espiritual de [Super Ventilagon](https://ventilagon.protocultura.net/) (2015) y [Reflektor](https://reflektor.protocultura.net/) (2013), los juegos electromecánicos del Club de Jaqueo.
{% endcapture %}
{% include home/centered-section.html id="que" style="style3" content=about %}

{% capture technology_esp32 %}
## Un chip ESP32 y 107 leds, girando a 600 RPM

El código de los juegos está hecho en Micropython, y montado en la hélice de un ventilador.
{% endcapture %}
{% capture technology_slip_ring %}
## Un anillo colector

La alimentación eléctrica y las señales de datos cruzan por un *slip ring* hacia la base, que usa una Raspberry Pi para reproducir la música y los efectos sonoros.
{% endcapture %}
{% capture technology_open %}
## El código y hardware son libres y abiertos

Si tenés un ventilador o lavarropa que ya no uses, podés armarte una Ventilastation en tu casa visitando [el repositorio del proyecto en GitHub](https://github.com/ventilastation/vsdk).
{% endcapture %}
{% include home/technology.html first=technology_esp32 second=technology_slip_ring third=technology_open %}

{% capture how_to_play %}
## ¿Cómo jugar Ventilastation?

En eventos relacionados a los juegos y al open source suele estar presente Ventilastation. Podés jugar ahí, o fabricarte una en tu casa.

Ventilastation tiene un joystick y una consola con botones, que se usan para distintos tipos de juegos:
{% endcapture %}
{% include home/centered-section.html id="como" style="style1" content=how_to_play %}

{% include home/game-showcase.html %}

{% capture media %}
## Qué opinan los medios
{% endcapture %}
{% include home/media-section.html content=media %}

{% capture make_games %}
## ¿Cómo hacer juegos para Ventilastation?

Para simplificar la creación de juegos para esta consola, se eligió el lenguaje [Micropython](https://micropython.org/).

Como ejemplo, el juego Vyruss consta de menos de 700 líneas y se puede ver en [el repositorio del proyecto](https://github.com/ventilastation/vsdk/blob/main/apps/micropython/apps/vyruss.py).
{% endcapture %}
{% include home/centered-section.html id="juegos" style="style1" content=make_games %}

{% capture build_hardware %}
## ¿Cómo fabricar una Ventilastation?

Todo el código fuente, los esquemáticos y los planos para armar Ventilastation están disponibles abiertamente, como software y hardware libre.

Si tenés un ventilador o lavarropa que ya no uses, podés armarte una Ventilastation en tu casa visitando [el repositorio del proyecto en GitHub](https://github.com/ventilastation/vsdk).
{% endcapture %}
{% include home/centered-section.html id="hardware" style="style3" content=build_hardware %}

{% capture credits %}
## Una consola hecha por alecu

Con la colaboración de muchos amigues:

- Tecnoestructuras
- Python Argentina
- GameOn!
- ArsGames
- EspacioTec
- Cybercirujas
- FlashParty

Algunos juegos anteriores:

- [Reflektor](http://reflektor.protocultura.net/) (2013)
- [Super Ventilagon](https://ventilagon.protocultura.net/) (2015)
- [Vigilen los Cielos](https://www.megajuegos.com.ar/) (2016)
{% endcapture %}
{% include home/call-to-action.html content=credits %}
