---
layout: landing
---

<div id="arriba">
  <a href="{{ '/en/' | relative_url }}">English</a>
</div>

<video autoplay loop muted poster="{{ '/images/banner.jpg' | relative_url }}" id="bgvid">
  <source src="{{ '/images/banner.mp4' | relative_url }}" type="video/mp4">
</video>

<section id="banner">
  <div class="inner" markdown="1">

## {{ site.title }}

{{ site.description }}

  </div>
  <ul class="actions">
    <li><a href="#que" class="scrolly button">¿Qué es?</a></li>
    <li><a href="#como" class="scrolly button">¿Cómo jugar?</a></li>
    <li><a href="#juegos" class="scrolly button">Hacé un juego</a></li>
    <li><a href="#hardware" class="scrolly button">Armate una</a></li>
  </ul>
  <a href="#que" class="more scrolly">Más info</a>
</section>

<section id="que" class="wrapper style3 special">
  <div class="inner">
    <header class="major" markdown="1">

## ¿Qué es Ventilastation?

Es una consola open source, para poder hacer y jugar videojuegos circulares. Íntegramente creada y fabricada en Argentina.

Es la sucesora espiritual de [Super Ventilagon](https://ventilagon.protocultura.net/) (2015) y [Reflektor](https://reflektor.protocultura.net/) (2013), los juegos electromecánicos del Club de Jaqueo.

</header>
  </div>
</section>

<section id="tecnologia" class="wrapper alt style2">
  <section class="spotlight">
    <div class="image"><img src="{{ '/images/pic01.jpg' | relative_url }}" alt="" /></div>
    <div class="content" markdown="1">

## Un chip ESP32 y 107 leds, girando a 600 RPM

El código de los juegos está hecho en Micropython, y montado en la hélice de un ventilador.

</div>
  </section>
  <section class="spotlight">
    <div class="image"><img src="{{ '/images/pic02.jpg' | relative_url }}" alt="" /></div>
    <div class="content" markdown="1">

## Un anillo colector

La alimentación eléctrica y las señales de datos cruzan por un *slip ring* hacia la base, que usa una Raspberry Pi para reproducir la música y los efectos sonoros.

</div>
  </section>
  <section class="spotlight">
    <div class="image"><img src="{{ '/images/pic03.jpg' | relative_url }}" alt="" /></div>
    <div class="content" markdown="1">

## El código y hardware son libres y abiertos

Si tenés un ventilador o lavarropa que ya no uses, podés armarte una Ventilastation en tu casa visitando [el repositorio del proyecto en GitHub](https://github.com/ventilastation/vsdk).

</div>
  </section>
</section>

<section id="como" class="wrapper style1 special">
  <div class="inner">
    <header class="major" markdown="1">

## ¿Cómo jugar Ventilastation?

En eventos relacionados a los juegos y al open source suele estar presente Ventilastation. Podés jugar ahí, o fabricarte una en tu casa.

Ventilastation tiene un joystick y una consola con botones, que se usan para distintos tipos de juegos:

</header>
  </div>
</section>

<section id="juegos-disponibles" class="wrapper alt style2">
  <section class="spotlight">
    <div class="fanshot"><img src="{{ '/images/vermu.png' | relative_url }}" alt="" /></div>
    <div class="content"><img src="{{ '/images/vermu-control.png' | relative_url }}" width="60%" alt="" /></div>
  </section>
  <section class="spotlight">
    <div class="fanshot"><img src="{{ '/images/vyruss.png' | relative_url }}" alt="" /></div>
    <div class="content"><img src="{{ '/images/vyruss-control.png' | relative_url }}" width="60%" alt="" /></div>
  </section>
  <section class="spotlight">
    <div class="fanshot"><img src="{{ '/images/ventilagon.png' | relative_url }}" alt="" /></div>
    <div class="content"><img src="{{ '/images/ventilagon-control.png' | relative_url }}" width="70%" alt="" /></div>
  </section>
</section>

<section id="medios" class="wrapper style3 special">
  <div class="inner">
    <header class="major" markdown="1">

## Qué opinan los medios

</header>
    <ul class="features">
      {% include media.html %}
    </ul>
  </div>
</section>

<section id="juegos" class="wrapper style1 special">
  <div class="inner">
    <header class="major" markdown="1">

## ¿Cómo hacer juegos para Ventilastation?

Para simplificar la creación de juegos para esta consola, se eligió el lenguaje [Micropython](https://micropython.org/).

Como ejemplo, el juego Vyruss consta de menos de 700 líneas y se puede ver en [el repositorio del proyecto](https://github.com/ventilastation/vsdk/blob/main/apps/micropython/apps/vyruss.py).

</header>
  </div>
</section>

<section id="hardware" class="wrapper style3 special">
  <div class="inner">
    <header class="major" markdown="1">

## ¿Cómo fabricar una Ventilastation?

Todo el código fuente, los esquemáticos y los planos para armar Ventilastation están disponibles abiertamente, como software y hardware libre.

Si tenés un ventilador o lavarropa que ya no uses, podés armarte una Ventilastation en tu casa visitando [el repositorio del proyecto en GitHub](https://github.com/ventilastation/vsdk).

</header>
  </div>
</section>

<section id="cta" class="wrapper style4">
  <div class="inner">
    <header markdown="1">

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

 </header>
    <ul class="actions vertical">
      <li><a href="mailto:ventilagon@protocultura.net" class="button fit special">Contactanos</a></li>
    </ul>
  </div>
</section>
