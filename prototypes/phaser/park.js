import { project, unproject, stepToward } from './world.mjs';

const park = await fetch('../godot-project/park.json').then(response => {
  if (!response.ok) throw new Error('Não foi possível carregar o parque.');
  return response.json();
}).catch(error => {
  parent.postMessage({ type: 'park-error', message: error.message }, location.origin);
  throw error;
});

function polygon(graphics, color, points) {
  graphics.fillStyle(color).fillPoints(points, true);
}

function makeDinosaur(scene) {
  const shape = scene.add.graphics();
  shape.fillStyle(0x559371).fillTriangle(-23, -38, -57, -23, -16, -21);
  shape.fillStyle(0x4b8565).fillRoundedRect(-20, -20, 12, 23, 5).fillRoundedRect(12, -19, 12, 22, 5);
  shape.fillStyle(0x83b588).fillEllipse(-2, -33, 66, 46);
  shape.fillStyle(0xb8d39a).fillEllipse(4, -27, 40, 27);
  shape.fillStyle(0x83b588).fillRoundedRect(7, -76, 23, 51, 10).fillEllipse(24, -76, 46, 35);
  shape.fillStyle(0x4b8565).fillRoundedRect(-10, -17, 12, 22, 5).fillRoundedRect(22, -16, 12, 21, 5);
  shape.fillStyle(0xb8d39a).fillEllipse(33, -69, 25, 13);
  shape.fillStyle(0x34584b).fillCircle(32, -82, 3.4).fillCircle(43, -73, 1.4);
  shape.fillStyle(0xffffff).fillCircle(33, -83, 1);
  shape.fillStyle(0xdaaa87, .65).fillEllipse(26, -72, 7, 4);
  shape.lineStyle(1.8, 0x466b51).beginPath().moveTo(34, -66).lineTo(40, -65).lineTo(44, -67).strokePath();
  shape.fillStyle(0xc6d6a1).fillCircle(-19, -43, 4).fillCircle(-8, -49, 4).fillCircle(4, -49, 3.5);
  return shape;
}

function makeTree(scene, x, z, size = 1, coral = false) {
  const point = project(x, z);
  const shadow = scene.add.ellipse(point.x, point.y + 3, 69 * size, 25 * size, 0x52775a, .13).setDepth(-850);
  const shape = scene.add.graphics();
  shape.fillStyle(0xa98c64).fillRoundedRect(-7, -61, 14, 64, 5);
  shape.fillStyle(coral ? 0xd99c8a : 0x71986a).fillCircle(-17, -65, 31).fillCircle(17, -69, 29).fillCircle(0, -91, 34);
  shape.fillStyle(coral ? 0xe7b19a : 0x93b47b).fillCircle(-13, -87, 24).fillCircle(12, -99, 22);
  shape.fillStyle(coral ? 0xefc2ab : 0xb2ca8b).fillEllipse(-10, -104, 17, 7);
  scene.add.container(point.x, point.y, [shape]).setScale(size).setDepth(point.y);
  return shadow;
}

function makeDiscovery(scene, item) {
  const point = project(...item.position);
  const ring = scene.add.ellipse(point.x, point.y + 3, 83, 40, 0xffffff, .4).setStrokeStyle(2, 0xffffff, .75).setDepth(-800);
  const shape = scene.add.graphics();
  if (item.id === 'flowers') {
    for (const [x, y, color] of [[-18, -8, 0xde9a91], [4, -22, 0xf0cf76], [24, -6, 0xdc968b]]) {
      shape.lineStyle(3, 0x81a372).lineBetween(x, y, x, 2);
      shape.fillStyle(color);
      for (let i = 0; i < 6; i++) shape.fillCircle(x + Math.cos(i * Math.PI / 3) * 7, y - 15 + Math.sin(i * Math.PI / 3) * 7, 5);
      shape.fillStyle(0xffedb2).fillCircle(x, y - 15, 4);
    }
  } else if (item.id === 'tracks') {
    for (const [x, y] of [[-18, -9], [12, 3], [2, -23]]) {
      shape.fillStyle(0xb5a17c).fillEllipse(x, y, 14, 18);
      shape.fillCircle(x - 6, y - 10, 3).fillCircle(x, y - 13, 3.5).fillCircle(x + 6, y - 10, 3);
    }
  } else {
    shape.fillStyle(0xbb9366).fillRoundedRect(-24, -23, 49, 29, 8);
    shape.fillStyle(0xd1b17b).fillRoundedRect(-27, -27, 55, 8, 4);
    for (const [x, y, color] of [[-15, -27, 0xe1ac5b], [1, -29, 0xd78d78], [17, -26, 0xe7bc69]]) {
      shape.fillStyle(color).fillCircle(x, y, 10);
      shape.fillStyle(0x7f9b60).fillEllipse(x + 3, y - 10, 9, 4);
    }
  }
  const object = scene.add.container(point.x, point.y, [shape]).setDepth(point.y);
  return { ...item, point, ring, object, found: false };
}

class ParkScene extends Phaser.Scene {
  create() {
    this.position = { x: park.start[0], z: park.start[1] };
    this.target = { ...this.position };
    this.cameras.main.setBackgroundColor('#e8f2ed');
    const graphics = this.add.graphics().setDepth(-1000);
    graphics.fillStyle(0xbcd2c4, .38).fillEllipse(482, 373, 770, 310);
    const corners = [[-4.2, -4.2], [4.2, -4.2], [4.2, 4.2], [-4.2, 4.2]].map(([x, z]) => project(x, z));
    polygon(graphics, 0xbda17d, [corners[1], corners[2], corners[3], { x: corners[3].x, y: corners[3].y + 25 }, { x: corners[2].x, y: corners[2].y + 25 }, { x: corners[1].x, y: corners[1].y + 25 }]);
    polygon(graphics, 0xcdb68c, [corners[0], corners[1], { x: corners[1].x, y: corners[1].y + 25 }, { x: corners[0].x, y: corners[0].y + 25 }]);
    polygon(graphics, 0xb8ce94, corners);
    for (let x = -3.5; x <= 3.5; x++) {
      for (let z = -3.5; z <= 3.5; z++) {
        if ((Math.round(x + z) + 10) % 3 !== 0) continue;
        const p = project(x, z);
        graphics.fillStyle(0xd0dfa8, .35).fillEllipse(p.x, p.y, 36, 13);
      }
    }
    const path = [[0, 3], [0, 1], [-1, 0], [-2.2, -1.3], [-.2, -1], [2.1, -1.7], [2, 0], [2.3, 1.8]];
    graphics.lineStyle(28, 0xd8d4a6, .85).beginPath();
    path.forEach(([x, z], i) => {
      const point = project(x, z);
      if (i === 0) graphics.moveTo(point.x, point.y);
      else graphics.lineTo(point.x, point.y);
    });
    graphics.strokePath();
    const pond = project(-2, 1.5);
    graphics.fillStyle(0x93bba6).fillEllipse(pond.x, pond.y, 143, 72);
    graphics.fillStyle(0xb0d7cb).fillEllipse(pond.x, pond.y - 3, 132, 61);
    graphics.lineStyle(2, 0xe3f2d9, .8).lineBetween(pond.x - 26, pond.y - 10, pond.x + 5, pond.y - 10).lineBetween(pond.x + 19, pond.y + 5, pond.x + 40, pond.y + 5);
    for (const [x, z, size, coral] of [[-3.7, -3.5, 1.12, false], [-1.3, -3.8, .83, false], [3.6, -3.4, 1, false], [3.8, .2, .86, true], [-3.9, 2.3, .72, false], [.5, 3.8, .6, false]]) makeTree(this, x, z, size, coral);
    for (const [x, z] of [[-3.4, -.5], [1, -3], [-2.9, 3], [3, 3.4]]) {
      const p = project(x, z);
      const rock = this.add.graphics().setDepth(p.y);
      rock.fillStyle(0xaab7a1).fillEllipse(p.x, p.y - 4, 33, 19);
      rock.fillStyle(0xc1ccae).fillEllipse(p.x - 4, p.y - 8, 24, 12);
    }
    this.discoveries = park.discoveries.map(item => makeDiscovery(this, item));
    this.marker = this.add.ellipse(0, 0, 32, 16).setStrokeStyle(2, 0xffffff, .9).setDepth(-700).setVisible(false);
    this.shadow = this.add.ellipse(0, 0, 68, 25, 0x52775a, .18).setDepth(-650);
    this.dinosaur = this.add.container(0, 0, [makeDinosaur(this)]);
    this.input.on('pointerdown', pointer => {
      const worldPoint = this.cameras.main.getWorldPoint(pointer.x, pointer.y);
      const nearby = this.discoveries.find(item => Math.hypot(item.point.x - worldPoint.x, item.point.y - 14 - worldPoint.y) < 48);
      this.target = nearby ? { x: nearby.position[0], z: nearby.position[1] } : unproject(worldPoint.x, worldPoint.y, park.bounds);
      const point = project(this.target.x, this.target.z);
      this.marker.setPosition(point.x, point.y).setVisible(true);
    });
    this.events.once('shutdown', () => this.input.removeAllListeners('pointerdown'));
    parent.postMessage({ type: 'park-ready' }, location.origin);
  }

  update(time, delta) {
    if (!this.position) return;
    const previous = this.position;
    this.position = stepToward(this.position, this.target, Math.min(delta, 50) / 1000 * 2.2);
    const moving = Math.hypot(this.position.x - previous.x, this.position.z - previous.z) > .0001;
    const point = project(this.position.x, this.position.z);
    if (moving) this.dinosaur.scaleX = project(this.target.x, this.target.z).x >= point.x ? 1 : -1;
    this.dinosaur.setPosition(point.x, point.y + Math.sin(time / (moving ? 95 : 650)) * (moving ? 3 : 1)).setDepth(point.y + 1);
    this.shadow.setPosition(point.x, point.y + 3);
    if (!moving) this.marker.setVisible(false);
    for (const item of this.discoveries) {
      item.ring.setAlpha(item.found ? .3 : .6 + Math.sin(time / 650) * .15);
      if (!item.found && Math.hypot(this.position.x - item.position[0], this.position.z - item.position[1]) < .65) {
        item.found = true;
        item.ring.setFillStyle(0xe4f2bf, .65).setStrokeStyle(2, 0xf4ffe1, 1);
        this.tweens.add({ targets: item.object, y: item.point.y - 16, duration: 380, yoyo: true, repeat: 1, ease: 'Sine.easeInOut' });
        for (let i = 0; i < 7; i++) {
          const sparkle = this.add.circle(item.point.x + Math.cos(i) * 25, item.point.y - 10, 3 + i % 2, 0xfff7cd).setDepth(1000);
          this.tweens.add({ targets: sparkle, y: item.point.y - 65 - i * 3, alpha: 0, duration: 1000, onComplete: () => sparkle.destroy() });
        }
        parent.postMessage({ type: 'park-discovery', id: item.id, message: item.message }, location.origin);
      }
    }
  }
}

new Phaser.Game({
  type: Phaser.AUTO,
  banner: false,
  parent: 'game',
  width: 960,
  height: 640,
  backgroundColor: '#e8f2ed',
  antialias: true,
  audio: { noAudio: true },
  scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH },
  scene: ParkScene
});
