import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:open_route_service/open_route_service.dart';
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

	OpenRouteService openrouteservice = OpenRouteService(apiKey: '');

	bool _darkMode = false;

	var polyCoords = [
		LatLng(40.8205124, -96.7040093),
		LatLng(40.8136168, -96.7040556),
		LatLng(40.8136231, -96.7055320),
		LatLng(40.8118775, -96.7055320),
	];

	var markers = [
		LatLng(40.8205124, -96.7040093),
		LatLng(40.8118775, -96.7055320)
	];

	/**
	 * Go to the default location
	 */
	void _gotoDefault() {
		controller.center = const LatLng(0,0);
		controller.zoom = 14;
		setState(() {});
	}

	/**
	 * Handle Double Taps
	 */
	void _onDoubleTap(MapTransformer transformer, Offset position) {
		const delta = 10;
		final zoom = clamp(controller.zoom + delta, 2, 18);

		transformer.setZoomInPlace(zoom, position);
		setState(() {});
	}

	Offset? _dragStart;
	double _scaleStart = 1.0;
	/**
	 * Starting Scale
	 */
	void _onScaleStart(ScaleStartDetails details) {
		_dragStart = details.focalPoint;
		_scaleStart = 1.0;
	}

	/**
	 * Handle Scale Updating
	 */
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

	/** 
	 * Utility function to convert waypoints to Positioned Widgets
	 * @params pos - Offset
	 * @params color - Color
	 * @return position
	 */
	Widget _buildMarkerWidget(Offset pos, Color color,
		[IconData icon = Icons.location_on]) {
		return Positioned(
			left: pos.dx - 24,
			top: pos.dy - 24,
			width: 48,
			height: 48,
			child: GestureDetector(
				child: Icon(
					icon,
					color: color,
					size: 48,
				),
				onTap: () {
					showDialog(
						context: context,
						builder: (context) => const AlertDialog(
							content: Text('You have clicked a marker!'),
						),
					);
				},
			),
		);
	}

	@override
	Widget build(BuildContext context) {

		// Create Polylines based on the data that we have.
		final polylines = <Polyline>[
			Polyline(
				data: polyCoords,
				paint: Paint()
				  ..strokeWidth = 4
				  ..color = Colors.red,
			)
		];
		
		// Create the map
		return MapLayout(
			controller: controller,
			builder: (context, transformer) {

				// Create the markers for later on.
				final markerPositions = markers.map(transformer.toOffset).toList();

				final markerWidgets = markerPositions.map(
					(pos) => _buildMarkerWidget(pos, Colors.red),
				);

				// Gesture Detections
				return GestureDetector(
					behavior: HitTestBehavior.opaque,
					onDoubleTapDown: (details) => _onDoubleTap(
						transformer,
						details.localPosition,
					),
					onScaleStart: _onScaleStart,
					onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
					onTapUp: (details) async {
						final location = transformer.toLatLng(details.localPosition);

						if(markers.length > 1){
							markers.clear();
							polyCoords.clear();
						}

						markers.add(LatLng(location.latitude, location.longitude));

						setState(() {});

						if(markers.length < 2){ return; }
						
						// Form Route between coordinates
						final Future<List<ORSCoordinate>> routeCoordinates = openrouteservice.directionsRouteCoordsGet(
							startCoordinate: ORSCoordinate(latitude: markers[0].latitude, longitude: markers[0].longitude),
							endCoordinate: ORSCoordinate(latitude: markers[1].latitude, longitude: markers[1].longitude),
						);

						routeCoordinates.then( (resp) {
							// resp.forEach(print);

							polyCoords = resp
								.map((coordinate) => LatLng(coordinate.latitude, coordinate.longitude))
								.toList();

							setState((){});
						}).catchError( (error) {
							showDialog(
								context: context,
								builder: (context) => const AlertDialog(
									content: Text('Unable to generate route!'),
								),
							);

							markers.clear();
							polyCoords.clear();
							setState(() {});
						});


						setState(() {});
					}, 
					child: Listener(
						behavior: HitTestBehavior.opaque,
						onPointerSignal: (event) {
							if (!(event is PointerScrollEvent)) {
								return;
							}

							// If the scroll delta is too much, edit me
							final delta = event.scrollDelta.dy / -100.0;
							final zoom = clamp(controller.zoom + delta, 2, 18);

							transformer.setZoomInPlace(zoom, event.localPosition);
							setState(() {});
						},
						child: Stack(
							children: [
								// Tiled Map Data
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

								// Polylines
								PolylineLayer(
									transformer: transformer,
									polylines: polylines,
								),

								// Markers
								...markerWidgets,
								
								// Custom Painter
								// Do we need this?
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