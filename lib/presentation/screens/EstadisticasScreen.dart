import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/EstadisticasController.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  late final EstadisticasController _controller;
  int _seccionTocadaIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = EstadisticasController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWebGlobal = MediaQuery.of(context).size.width > 900;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1046C4)))
              : SingleChildScrollView(
            padding: EdgeInsets.all(isWebGlobal ? 40.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),

                // 👉 GRÁFICOS RESPONSIVOS (Ocupando todo el ancho)
                isWebGlobal
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Gráfico de Barras (Ocupa 2 partes del espacio)
                    Expanded(
                      flex: 2,
                      child: _buildGraficoBarras(),
                    ),
                    const SizedBox(width: 24), // Espacio entre los dos
                    // 2. Gráfico de Anillo (Ocupa 1 parte del espacio)
                    Expanded(
                      flex: 1,
                      child: _buildGraficoAnillo(),
                    ),
                  ],
                )
                    : Column(
                  // Si es celular, se apilan uno debajo del otro
                  children: [
                    SizedBox(width: double.infinity, child: _buildGraficoBarras()),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: _buildGraficoAnillo()),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. Ranking de Empresas (Ocupa todo el ancho disponible)
                _buildRankingEmpresas(),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Estadísticas", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Text("Métricas de rendimiento y flujo de ingresos.", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
      ],
    );
  }

  // --- 1. GRÁFICO DE BARRAS (Ya corregido) ---
  Widget _buildGraficoBarras() {
    if (_controller.ingresosPorQuincena.isEmpty) {
      return _buildTarjetaVacia("Ingresos por Quincena", "No hay ingresos registrados.");
    }

    List<String> quincenas = _controller.ingresosPorQuincena.keys.toList();
    List<double> montos = _controller.ingresosPorQuincena.values.toList();

    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ingresos por Quincena", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 40),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _controller.maxIngreso * 1.2,
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  horizontalInterval: (_controller.maxIngreso / 4) == 0 ? 1 : (_controller.maxIngreso / 4),
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 45,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(meta: meta, child: Text("\$${value.toInt()}", style: TextStyle(color: Colors.grey.shade500, fontSize: 10)));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= quincenas.length) return const SizedBox.shrink();
                        return SideTitleWidget(meta: meta, child: Text(quincenas[index], style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)));
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(quincenas.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: montos[index],
                        color: const Color(0xFF1046C4),
                        width: 24,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(show: true, toY: _controller.maxIngreso * 1.2, color: Colors.grey.shade100),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. GRÁFICO DE ANILLO ---
  Widget _buildGraficoAnillo() {
    if (_controller.totalCobrado == 0 && _controller.totalPendiente == 0) {
      return _buildTarjetaVacia("Distribución", "No hay presupuesto asignado.");
    }

    // 👉 1. Variables para calcular el texto central dinámico
    String textoCentro = "Total";
    String valorCentro = "\$${(_controller.totalCobrado + _controller.totalPendiente).toInt()}";

    // Si el usuario toca una sección, cambiamos el texto del centro
    if (_seccionTocadaIndex == 0) {
      textoCentro = "Cobrado";
      valorCentro = "\$${_controller.totalCobrado.toInt()}";
    } else if (_seccionTocadaIndex == 1) {
      textoCentro = "Pendiente";
      valorCentro = "\$${_controller.totalPendiente.toInt()}";
    }

    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Presupuesto General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          // Si el usuario quita el mouse o levanta el dedo, reseteamos a -1
                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                            _seccionTocadaIndex = -1;
                            return;
                          }
                          // Guardamos el índice de la sección que está tocando
                          _seccionTocadaIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),


                    sectionsSpace: 4,
                    centerSpaceRadius: 70, // Esto crea el agujero del "anillo"
                    sections: [
                      PieChartSectionData(
                        // 👉 Azul principal de la app para lo COBRADO
                        color: const Color(0xFF1046C4),
                        value: _controller.totalCobrado,
                        title: 'Cobrado',
                        radius: _seccionTocadaIndex == 0 ? 40 : 30,
                        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        // 👉 Gris sutil y elegante para lo PENDIENTE
                        color: Colors.grey.shade300,
                        value: _controller.totalPendiente,
                        title: 'Pendiente',
                        radius: _seccionTocadaIndex == 1 ? 40 : 30,
                        // Cambiamos la letra a un gris oscuro para que resalte sobre el fondo claro
                        titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                // Texto en el centro del anillo
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(textoCentro, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      valorCentro,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1046C4)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. RANKING DE EMPRESAS ---
  Widget _buildRankingEmpresas() {
    if (_controller.rankingEmpresas.isEmpty) return const SizedBox.shrink();

    // Encontrar el valor máximo para calcular los porcentajes de las barras
    double maxPresupuesto = _controller.rankingEmpresas.first.value;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Top Aliados Estratégicos (Por Presupuesto)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 24),
          ..._controller.rankingEmpresas.map((entrada) {
            double porcentaje = maxPresupuesto > 0 ? (entrada.value / maxPresupuesto) : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entrada.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5C6BC0))),
                      Text("\$${entrada.value.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: porcentaje,
                      backgroundColor: Colors.grey.shade100,
                      color: const Color(0xFF1046C4),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helper para mostrar un mensaje si no hay datos
  Widget _buildTarjetaVacia(String titulo, String mensaje) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          const Spacer(),
          Center(child: Text(mensaje, style: TextStyle(color: Colors.grey.shade500))),
          const Spacer(),
        ],
      ),
    );
  }
}