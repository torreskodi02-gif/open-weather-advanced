import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/settings_service.dart';
import '../services/weather_service.dart';
import 'settings_screen.dart';
import 'radar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _place;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    final last = context.read<SettingsService>().lastCity;
    if (last != null && last.isNotEmpty) {
      _searchController.text = last;
      _loadCity(last);
    } else {
      _loadCity('London');
    }
  }

  Future<void> _loadCity(String name) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final weather = context.read<WeatherService>();
      final place = await weather.searchCity(name);
      if (place == null) {
        setState(() {
          _error = 'City not found';
          _loading = false;
        });
        return;
      }
      final data = await weather.getForecast(
        (place['latitude'] as num).toDouble(),
        (place['longitude'] as num).toDouble(),
      );
      await context.read<SettingsService>().setLastCity(name);
      setState(() {
        _place = place;
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _weatherText(int code) {
    const map = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Fog',
      48: 'Rime fog',
      51: 'Light drizzle',
      53: 'Drizzle',
      55: 'Dense drizzle',
      61: 'Slight rain',
      63: 'Rain',
      65: 'Heavy rain',
      71: 'Slight snow',
      73: 'Snow',
      75: 'Heavy snow',
      80: 'Rain showers',
      81: 'Rain showers',
      82: 'Violent showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm',
      99: 'Thunderstorm',
    };
    return map[code] ?? 'Unknown';
  }

  String _icon(int code) {
    if (code == 0) return '☀️';
    if (code <= 2) return '🌤️';
    if (code == 3) return '☁️';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '🌨️';
    if (code <= 82) return '🌦️';
    return '⛈️';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final useC = settings.useCelsius;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RadarScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search city…',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (v) {
                        if (v.trim().isNotEmpty) _loadCity(v.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final v = _searchController.text.trim();
                      if (v.isNotEmpty) _loadCity(v);
                    },
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),

            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ),
              )
            else if (_data != null && _place != null)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadCity(_searchController.text.trim()),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Current
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                '${_place!['name']}${_place!['admin1'] != null ? ', ${_place!['admin1']}' : ''}',
                                style: theme.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _icon((_data!['current']['weather_code'] as num).toInt()),
                                style: const TextStyle(fontSize: 64),
                              ),
                              Text(
                                '${(_data!['current']['temperature_2m'] as num).round()}°${useC ? 'C' : 'F'}',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                _weatherText((_data!['current']['weather_code'] as num).toInt()),
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Feels like ${(_data!['current']['apparent_temperature'] as num).round()}°',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Details
                      Row(
                        children: [
                          _DetailChip(
                            icon: Icons.water_drop_outlined,
                            label: 'Humidity',
                            value: '${_data!['current']['relative_humidity_2m']}%',
                          ),
                          const SizedBox(width: 8),
                          _DetailChip(
                            icon: Icons.air,
                            label: 'Wind',
                            value: '${(_data!['current']['wind_speed_10m'] as num).round()} km/h',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _DetailChip(
                            icon: Icons.umbrella_outlined,
                            label: 'Precip',
                            value: '${_data!['current']['precipitation']} mm',
                          ),
                          const SizedBox(width: 8),
                          _DetailChip(
                            icon: Icons.wb_sunny_outlined,
                            label: 'UV',
                            value: '${_data!['current']['uv_index'] ?? '—'}',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Text('Next hours', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 24,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final times = _data!['hourly']['time'] as List;
                            final temps = _data!['hourly']['temperature_2m'] as List;
                            final codes = _data!['hourly']['weather_code'] as List;
                            if (i >= times.length) return const SizedBox();
                            final t = DateTime.parse(times[i]);
                            return Card(
                              child: SizedBox(
                                width: 72,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat.Hm().format(t),
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      Text(_icon((codes[i] as num).toInt()), style: const TextStyle(fontSize: 22)),
                                      Text(
                                        '${(temps[i] as num).round()}°',
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text('7-day forecast', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...List.generate(7, (i) {
                        final times = _data!['daily']['time'] as List;
                        final maxs = _data!['daily']['temperature_2m_max'] as List;
                        final mins = _data!['daily']['temperature_2m_min'] as List;
                        final codes = _data!['daily']['weather_code'] as List;
                        if (i >= times.length) return const SizedBox();
                        final d = DateTime.parse(times[i]);
                        final name = i == 0 ? 'Today' : DateFormat.E().format(d);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            leading: Text(_icon((codes[i] as num).toInt()), style: const TextStyle(fontSize: 28)),
                            title: Text(name),
                            trailing: Text(
                              '${(maxs[i] as num).round()}° / ${(mins[i] as num).round()}°',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelSmall),
                  Text(value, style: theme.textTheme.titleSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
