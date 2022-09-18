import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

import 'package:road_risk/utils/TileServers.dart';
import 'package:road_risk/utils/Utils.dart';
import 'package:road_risk/utils/ViewportPainter.dart';


class MapScreen extends StatefulWidget {
	const MapScreen({Key? key}) : super(key: key);

	@override
	MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
	final controller = MapController(
		location: const LatLng(0, 0),
		zoom: 6,
	);

	bool _darkMode = false;

	static const polyCoords = [
		LatLng(40.8205124, -96.7040093),
		LatLng(40.8136168, -96.7040556),
		LatLng(40.8136231, -96.7055320),
		LatLng(40.8118775, -96.7055320),
	];

	void _gotoDefault() {
		controller.center = const LatLng(0,0);
		controller.zoom = 14;
		setState(() {});
	}

	void _onDoubleTap(MapTransformer transformer, Offset position) {
		const delta = 10;
		final zoom = clamp(controller.zoom + delta, 2, 18);

		transformer.setZoomInPlace(zoom, position);
		setState(() {});
	}

	Offset? _dragStart;
	double _scaleStart = 1.0;
	void _onScaleStart(ScaleStartDetails details) {
		_dragStart = details.focalPoint;
		_scaleStart = 1.0;
	}

	void _onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
		final scaleDiff = details.scale - _scaleStart;
		_scaleStart = details.scale;

		if (scaleDiff > 0) {
			controller.zoom += 10;
			setState(() {});
			return;
		} 

		if (scaleDiff < 0) {
			controller.zoom -= 10;
			if (controller.zoom < 1) {
				controller.zoom = 1;
			}
			setState(() {});
			return;
		}

		final now = details.focalPoint;
		var diff = now - _dragStart!;
		_dragStart = now;
		final h = transformer.constraints.maxHeight;

		final vp = transformer.getViewport();
		if (diff.dy < 0 && vp.bottom - diff.dy < h) {
			diff = Offset(diff.dx, 0);
		}

		if (diff.dy > 0 && vp.top - diff.dy > 0) {
			diff = Offset(diff.dx, 0);
		}

		transformer.drag(diff.dx, diff.dy);
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		final polylines = <Polyline>[
			Polyline(
				data: polyCoords,
				paint: Paint()
				  ..strokeWidth = 4
				  ..color = Colors.red,
			)
		];
		
		return MapLayout(
			controller: controller,
			builder: (context, transformer) {
				return GestureDetector(
					behavior: HitTestBehavior.opaque,
					onDoubleTapDown: (details) => _onDoubleTap(
						transformer,
						details.localPosition,
					),
					onScaleStart: _onScaleStart,
					onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
					child: Listener(
						behavior: HitTestBehavior.opaque,
						onPointerSignal: (event) {
							if (!(event is PointerScrollEvent)) {
								return;
							}
							final delta = event.scrollDelta.dy / -100.0;
							final zoom = clamp(controller.zoom + delta, 2, 18);

							transformer.setZoomInPlace(zoom, event.localPosition);
							setState(() {});
						},
						child: Stack(
							children: [
								TileLayer(
									builder: (context, x, y, z) {
										final tilesInZoom = pow(2.0, z).floor();

										while (x < 0) {
											x += tilesInZoom;
										}
										while (y < 0) {
											y += tilesInZoom;
										}

										x %= tilesInZoom;
										y %= tilesInZoom;

										return CachedNetworkImage(
											imageUrl: OSM(z, x, y),
											fit: BoxFit.cover,
										);
									},
								),
								PolylineLayer(
									transformer: transformer,
									polylines: polylines,
								),
								CustomPaint(
									painter: ViewportPainter(
										transformer.getViewport(),
									),
								),
							],
						),
					),
				);
			},
		);
	}

}