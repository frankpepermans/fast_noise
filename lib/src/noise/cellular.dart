import 'dart:math' as math;

import 'package:fast_noise/src/types.dart';
import 'package:fast_noise/src/utils.dart';

import 'package:fast_noise/src/noise/enums.dart';

class CellularNoise {
  static const double gradientPerturbAmp = 1.0 / 0.45;

  final int seed, octaves;
  final double frequency, lacunarity, gain;
  final Interp interp;
  final CellularDistanceFunction cellularDistanceFunction;
  final CellularReturnType cellularReturnType;
  final double fractalBounding;

  CellularNoise(
      {this.seed = 1337,
      this.frequency = .01,
      this.interp = Interp.Quintic,
      this.octaves = 3,
      this.lacunarity = 2.0,
      this.gain = .5,
      this.cellularDistanceFunction = CellularDistanceFunction.Euclidean,
      this.cellularReturnType = CellularReturnType.CellValue})
      : fractalBounding = calculateFractalBounding(gain, octaves);

  double getCellular3(double x, double y, double z) {
    x *= frequency;
    y *= frequency;
    z *= frequency;

    switch (cellularReturnType) {
      case CellularReturnType.CellValue:
      case CellularReturnType.Distance:
        return singleCellular3(x, y, z);
      default:
        return singleCellular2Edge3(x, y, z);
    }
  }

  double singleCellular3(double x, double y, double z) {
    final xr = x.round(), yr = y.round(), zr = z.round();

    var distance = 999999.0;
    var xc = 0, yc = 0, zc = 0;

    switch (cellularDistanceFunction) {
      case CellularDistanceFunction.Euclidean:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            for (var zi = zr - 1; zi <= zr + 1; zi++) {
              final vec = CELL_3D[hash3D(seed, xi, yi, zi) & 255];

              final vecX = xi - x + vec.x,
                  vecY = yi - y + vec.y,
                  vecZ = zi - z + vec.z,
                  newDistance = vecX * vecX + vecY * vecY + vecZ * vecZ;

              if (newDistance < distance) {
                distance = newDistance;
                xc = xi;
                yc = yi;
                zc = zi;
              }
            }
          }
        }
        break;
      case CellularDistanceFunction.Manhattan:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            for (var zi = zr - 1; zi <= zr + 1; zi++) {
              final vec = CELL_3D[hash3D(seed, xi, yi, zi) & 255];

              final vecX = xi - x + vec.x,
                  vecY = yi - y + vec.y,
                  vecZ = zi - z + vec.z,
                  newDistance = vecX.abs() + vecY.abs() + vecZ.abs();

              if (newDistance < distance) {
                distance = newDistance;
                xc = xi;
                yc = yi;
                zc = zi;
              }
            }
          }
        }
        break;
      case CellularDistanceFunction.Natural:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            for (var zi = zr - 1; zi <= zr + 1; zi++) {
              final vec = CELL_3D[hash3D(seed, xi, yi, zi) & 255];

              final vecX = xi - x + vec.x,
                  vecY = yi - y + vec.y,
                  vecZ = zi - z + vec.z,
                  newDistance = (vecX.abs() + vecY.abs() + vecZ.abs()) +
                      (vecX * vecX + vecY * vecY + vecZ * vecZ);

              if (newDistance < distance) {
                distance = newDistance;
                xc = xi;
                yc = yi;
                zc = zi;
              }
            }
          }
        }
        break;
    }

    switch (cellularReturnType) {
      case CellularReturnType.CellValue:
        return valCoord3D(0, xc, yc, zc);

      case CellularReturnType.Distance:
        return distance - 1.0;
      default:
        return .0;
    }
  }

  double singleCellular2Edge3(double x, double y, double z) {
    final xr = x.round(), yr = y.round(), zr = z.round();
    var distance = 999999.0, distance2 = 999999.0;

    switch (cellularDistanceFunction) {
      case CellularDistanceFunction.Euclidean:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            for (var zi = zr - 1; zi <= zr + 1; zi++) {
              final vec = CELL_3D[hash3D(seed, xi, yi, zi) & 255];

              final vecX = xi - x + vec.x,
                  vecY = yi - y + vec.y,
                  vecZ = zi - z + vec.z,
                  newDistance = vecX * vecX + vecY * vecY + vecZ * vecZ;

              distance2 = math.max(math.min(distance2, newDistance), distance);
              distance = math.min(distance, newDistance);
            }
          }
        }
        break;
      case CellularDistanceFunction.Manhattan:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            for (var zi = zr - 1; zi <= zr + 1; zi++) {
              final vec = CELL_3D[hash3D(seed, xi, yi, zi) & 255];

              final vecX = xi - x + vec.x,
                  vecY = yi - y + vec.y,
                  vecZ = zi - z + vec.z,
                  newDistance = vecX.abs() + vecY.abs() + vecZ.abs();

              distance2 = math.max(math.min(distance2, newDistance), distance);
              distance = math.min(distance, newDistance);
            }
          }
        }
        break;
      case CellularDistanceFunction.Natural:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            for (var zi = zr - 1; zi <= zr + 1; zi++) {
              final vec = CELL_3D[hash3D(seed, xi, yi, zi) & 255];

              final vecX = xi - x + vec.x,
                  vecY = yi - y + vec.y,
                  vecZ = zi - z + vec.z,
                  newDistance = (vecX.abs() + vecY.abs() + vecZ.abs()) +
                      (vecX * vecX + vecY * vecY + vecZ * vecZ);

              distance2 = math.max(math.min(distance2, newDistance), distance);
              distance = math.min(distance, newDistance);
            }
          }
        }
        break;
      default:
        break;
    }

    switch (cellularReturnType) {
      case CellularReturnType.Distance2:
        return distance2 - 1.0;
      case CellularReturnType.Distance2Add:
        return distance2 + distance - 1.0;
      case CellularReturnType.Distance2Sub:
        return distance2 - distance - 1.0;
      case CellularReturnType.Distance2Mul:
        return distance2 * distance - 1.0;
      case CellularReturnType.Distance2Div:
        return distance / distance2 - 1.0;
      default:
        return .0;
    }
  }

  double getCellular2(double x, double y) {
    x *= frequency;
    y *= frequency;

    switch (cellularReturnType) {
      case CellularReturnType.CellValue:
      case CellularReturnType.Distance:
        return singleCellular2(x, y);
      default:
        return singleCellular2Edge2(x, y);
    }
  }

  double singleCellular2(double x, double y) {
    final xr = x.round(), yr = y.round();
    var distance = 999999.0;
    var xc = 0, yc = 0;

    switch (cellularDistanceFunction) {
      case CellularDistanceFunction.Euclidean:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            final vec = CELL_2D[hash2D(seed, xi, yi) & 255];

            final vecX = xi - x + vec.x,
                vecY = yi - y + vec.y,
                newDistance = vecX * vecX + vecY * vecY;

            if (newDistance < distance) {
              distance = newDistance;
              xc = xi;
              yc = yi;
            }
          }
        }
        break;
      case CellularDistanceFunction.Manhattan:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            final vec = CELL_2D[hash2D(seed, xi, yi) & 255];

            final vecX = xi - x + vec.x,
                vecY = yi - y + vec.y,
                newDistance = (vecX.abs() + vecY.abs());

            if (newDistance < distance) {
              distance = newDistance;
              xc = xi;
              yc = yi;
            }
          }
        }
        break;
      case CellularDistanceFunction.Natural:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            final vec = CELL_2D[hash2D(seed, xi, yi) & 255];

            final vecX = xi - x + vec.x,
                vecY = yi - y + vec.y,
                newDistance =
                    (vecX.abs() + vecY.abs()) + (vecX * vecX + vecY * vecY);

            if (newDistance < distance) {
              distance = newDistance;
              xc = xi;
              yc = yi;
            }
          }
        }
        break;
    }

    switch (cellularReturnType) {
      case CellularReturnType.CellValue:
        return valCoord2D(0, xc, yc);

      case CellularReturnType.Distance:
        return distance - 1.0;
      default:
        return .0;
    }
  }

  double singleCellular2Edge2(double x, double y) {
    final xr = x.round(), yr = y.round();
    var distance = 999999.0, distance2 = 999999.0;

    switch (cellularDistanceFunction) {
      case CellularDistanceFunction.Euclidean:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            final vec = CELL_2D[hash2D(seed, xi, yi) & 255];

            final vecX = xi - x + vec.x,
                vecY = yi - y + vec.y,
                newDistance = vecX * vecX + vecY * vecY;

            distance2 = math.max(math.min(distance2, newDistance), distance);
            distance = math.min(distance, newDistance);
          }
        }
        break;
      case CellularDistanceFunction.Manhattan:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            final vec = CELL_2D[hash2D(seed, xi, yi) & 255];

            final vecX = xi - x + vec.x,
                vecY = yi - y + vec.y,
                newDistance = vecX.abs() + vecY.abs();

            distance2 = math.max(math.min(distance2, newDistance), distance);
            distance = math.min(distance, newDistance);
          }
        }
        break;
      case CellularDistanceFunction.Natural:
        for (var xi = xr - 1; xi <= xr + 1; xi++) {
          for (var yi = yr - 1; yi <= yr + 1; yi++) {
            final vec = CELL_2D[hash2D(seed, xi, yi) & 255];

            final vecX = xi - x + vec.x,
                vecY = yi - y + vec.y,
                newDistance =
                    (vecX.abs() + vecY.abs()) + (vecX * vecX + vecY * vecY);

            distance2 = math.max(math.min(distance2, newDistance), distance);
            distance = math.min(distance, newDistance);
          }
        }
        break;
    }

    switch (cellularReturnType) {
      case CellularReturnType.Distance2:
        return distance2 - 1.0;
      case CellularReturnType.Distance2Add:
        return distance2 + distance - 1.0;
      case CellularReturnType.Distance2Sub:
        return distance2 - distance - 1.0;
      case CellularReturnType.Distance2Mul:
        return distance2 * distance - 1.0;
      case CellularReturnType.Distance2Div:
        return distance / distance2 - 1.0;
      default:
        return .0;
    }
  }

  void gradientPerturb3(Vector3f v3) =>
      singleGradientPerturb3(seed, gradientPerturbAmp, frequency, v3);

  void gradientPerturbFractal3(Vector3f v3) {
    var seed = this.seed;
    var amp = gradientPerturbAmp * fractalBounding, freq = frequency;

    singleGradientPerturb3(seed, amp, frequency, v3);

    for (var i = 1; i < octaves; i++) {
      freq *= lacunarity;
      amp *= gain;
      singleGradientPerturb3(++seed, amp, freq, v3);
    }
  }

  void singleGradientPerturb3(
      int seed, double perturbAmp, double frequency, Vector3f v3) {
    final xf = v3.x * frequency, yf = v3.y * frequency, zf = v3.z * frequency;
    var x0 = xf.floor(),
        y0 = yf.floor(),
        z0 = zf.floor(),
        x1 = x0 + 1,
        y1 = y0 + 1,
        z1 = z0 + 1;

    double xs, ys, zs;
    switch (interp) {
      case Interp.Linear:
        xs = xf - x0;
        ys = yf - y0;
        zs = zf - z0;
        break;
      case Interp.Hermite:
        xs = (xf - x0).interpHermiteFunc;
        ys = (yf - y0).interpHermiteFunc;
        zs = (zf - z0).interpHermiteFunc;
        break;
      case Interp.Quintic:
        xs = (xf - x0).interpQuinticFunc;
        ys = (yf - y0).interpQuinticFunc;
        zs = (zf - z0).interpQuinticFunc;
        break;
    }

    var vec0 = CELL_3D[hash3D(seed, x0, y0, z0) & 255],
        vec1 = CELL_3D[hash3D(seed, x1, y0, z0) & 255];

    var lx0x = xs.lerp(vec0.x, vec1.x),
        ly0x = xs.lerp(vec0.y, vec1.y),
        lz0x = xs.lerp(vec0.z, vec1.z);

    vec0 = CELL_3D[hash3D(seed, x0, y1, z0) & 255];
    vec1 = CELL_3D[hash3D(seed, x1, y1, z0) & 255];

    var lx1x = xs.lerp(vec0.x, vec1.x),
        ly1x = xs.lerp(vec0.y, vec1.y),
        lz1x = xs.lerp(vec0.z, vec1.z),
        lx0y = ys.lerp(lx0x, lx1x),
        ly0y = ys.lerp(ly0x, ly1x),
        lz0y = ys.lerp(lz0x, lz1x);

    vec0 = CELL_3D[hash3D(seed, x0, y0, z1) & 255];
    vec1 = CELL_3D[hash3D(seed, x1, y0, z1) & 255];

    lx0x = xs.lerp(vec0.x, vec1.x);
    ly0x = xs.lerp(vec0.y, vec1.y);
    lz0x = xs.lerp(vec0.z, vec1.z);

    vec0 = CELL_3D[hash3D(seed, x0, y1, z1) & 255];
    vec1 = CELL_3D[hash3D(seed, x1, y1, z1) & 255];

    lx1x = xs.lerp(vec0.x, vec1.x);
    ly1x = xs.lerp(vec0.y, vec1.y);
    lz1x = xs.lerp(vec0.z, vec1.z);

    v3.x += zs.lerp(lx0y, ys.lerp(lx0x, lx1x)) * perturbAmp;
    v3.y += zs.lerp(ly0y, ys.lerp(ly0x, ly1x)) * perturbAmp;
    v3.z += zs.lerp(lz0y, ys.lerp(lz0x, lz1x)) * perturbAmp;
  }

  void gradientPerturb2(Vector2f v2) =>
      singleGradientPerturb2(seed, gradientPerturbAmp, frequency, v2);

  void gradientPerturbFractal2(Vector2f v2) {
    var seed = this.seed;
    var amp = gradientPerturbAmp * fractalBounding, freq = frequency;

    singleGradientPerturb2(seed, amp, frequency, v2);

    for (var i = 1; i < octaves; i++) {
      freq *= lacunarity;
      amp *= gain;
      singleGradientPerturb2(++seed, amp, freq, v2);
    }
  }

  void singleGradientPerturb2(
      int seed, double perturbAmp, double frequency, Vector2f v2) {
    final xf = v2.x * frequency, yf = v2.y * frequency;
    final x0 = xf.floor(), y0 = yf.floor(), x1 = x0 + 1, y1 = y0 + 1;

    double xs, ys;
    switch (interp) {
      case Interp.Linear:
        xs = xf - x0;
        ys = yf - y0;
        break;
      case Interp.Hermite:
        xs = (xf - x0).interpHermiteFunc;
        ys = (yf - y0).interpHermiteFunc;
        break;
      case Interp.Quintic:
        xs = (xf - x0).interpQuinticFunc;
        ys = (yf - y0).interpQuinticFunc;
        break;
    }

    var vec0 = CELL_2D[hash2D(seed, x0, y0) & 255],
        vec1 = CELL_2D[hash2D(seed, x1, y0) & 255];

    final lx0x = xs.lerp(vec0.x, vec1.x), ly0x = xs.lerp(vec0.y, vec1.y);

    vec0 = CELL_2D[hash2D(seed, x0, y1) & 255];
    vec1 = CELL_2D[hash2D(seed, x1, y1) & 255];

    final lx1x = xs.lerp(vec0.x, vec1.x), ly1x = xs.lerp(vec0.y, vec1.y);

    v2.x += ys.lerp(lx0x, lx1x) * perturbAmp;
    v2.y += ys.lerp(ly0x, ly1x) * perturbAmp;
  }
}
