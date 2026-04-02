import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class CargarTrabajoScreen extends StatefulWidget {
  const CargarTrabajoScreen({super.key});

  @override
  State<CargarTrabajoScreen> createState() => _CargarTrabajoScreenState();
}

class _CargarTrabajoScreenState extends State<CargarTrabajoScreen> {
  String? _empresaSeleccionada = 'Seleccione una empresa';
  String? _nivelSeleccionado = 'Seleccione el nivel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isWeb ? 40 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isWeb),
                  const SizedBox(height: 30),

                  // ---------------------------------------------------
                  // TARJETA 1: INFORMACIÓN GENERAL
                  // ---------------------------------------------------
                  _buildCardContainer(
                    isWeb: isWeb,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(Icons.sort, "Información General"),
                        const SizedBox(height: 24),

                        _buildResponsiveRow(
                          isWeb,
                          _buildTextField("CÓDIGO DE INVESTIGACIÓN", "Ej: INV-2024-001"),
                          _buildDropdown("EMPRESA CONTRATANTE", _empresaSeleccionada, ['Seleccione una empresa', 'CAAP', 'Otra'], (v) => setState(() => _empresaSeleccionada = v)),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField("TÍTULO DE LA INVESTIGACIÓN", isWeb ? "Ej. Impacto de la IA en la educación superior" : "Nombre descriptivo del proyecto"),
                        const SizedBox(height: 20),

                        _buildTextField("DESCRIPCIÓN DETALLADA", isWeb ? "Describa los objetivos, metodología y alcance esperado de su investigación..." : "Proporcione contexto académico y objetivos específicos...", maxLines: 4),
                        const SizedBox(height: 20),

                        _buildResponsiveRow(
                          isWeb,
                          _buildTextField("UNIVERSIDAD", isWeb ? "Ej. Universidad Central" : "Nombre"),
                          _buildDropdown("NIVEL EDUCATIVO", _nivelSeleccionado, ['Seleccione el nivel', 'Tecnología', 'Licenciatura', 'Maestría'], (v) => setState(() => _nivelSeleccionado = v)),
                        ),
                        const SizedBox(height: 20),

                        // EN MÓVIL: Valor Total va aquí dentro de Información General
                        if (!isWeb) ...[
                          _buildTextField("VALOR TOTAL", "\$ 0.00", isNumber: true),
                          const SizedBox(height: 20),
                        ],

                        _buildUploadArea(isWeb),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------------------------------------------------
                  // SECCIÓN 2: ACTIVIDADES E HITOS
                  // ---------------------------------------------------
                  if (isWeb) ...[
                    // Versión Web: Tarjeta con lista de actividades
                    _buildCardContainer(
                      isWeb: isWeb,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle(Icons.format_list_bulleted, "Actividades e Hitos"),
                              TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add_circle, color: Color(0xFF1046C4)),
                                  label: const Text("Añadir Actividad", style: TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold))
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildWebActivityRow(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Versión Web: Tarjeta independiente para Valor Total
                    _buildCardContainer(
                      isWeb: isWeb,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField("VALOR TOTAL", "\$ 0.00", isNumber: true),
                                const SizedBox(height: 16),
                                _buildInfoBox(),
                              ],
                            ),
                          ),
                          const Expanded(flex: 1, child: SizedBox()), // Espacio vacío a la derecha
                        ],
                      ),
                    ),
                  ] else ...[
                    // Versión Móvil: Título suelto + Tarjeta de actividad + Botón punteado
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: _buildSectionTitle(Icons.checklist_rtl_outlined, "Actividades e Hitos"),
                    ),
                    const SizedBox(height: 16),
                    _buildAppActivityCard(),
                    const SizedBox(height: 16),
                    _buildDottedButton("AÑADIR ACTIVIDAD", Icons.add_circle),
                  ],

                  const SizedBox(height: 40),

                  // ---------------------------------------------------
                  // BOTONES INFERIORES
                  // ---------------------------------------------------
                  _buildActionButtons(isWeb),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCCIÓN ---

  Widget _buildHeader(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(isWeb ? "Cargar Nuevo Trabajo" : "Cargar Nuevo Trabajo", style: TextStyle(fontSize: isWeb ? 32 : 28, fontWeight: FontWeight.bold, height: 1.2)),
        if (isWeb) const SizedBox(height: 8),
        if (isWeb) const Text("Complete los detalles de su nueva investigación académica para iniciar el seguimiento institucional.", style: TextStyle(color: Colors.grey, fontSize: 16)),
        if (!isWeb) Container(margin: const EdgeInsets.only(top: 8), height: 3, width: 40, color: const Color(0xFF1046C4)),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child, required bool isWeb}) {
    // En web tiene borde y sin sombra; en móvil tiene sombra suave.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 30 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 24 : 16),
        border: isWeb ? Border.all(color: Colors.grey.shade100) : null,
        boxShadow: isWeb ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1046C4), size: 20),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildResponsiveRow(bool isWeb, Widget child1, Widget child2) {
    if (isWeb) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child1),
          const SizedBox(width: 24),
          Expanded(child: child2),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [child1, const SizedBox(height: 20), child2],
      );
    }
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1, bool isNumber = false, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: isNumber ? FontWeight.bold : FontWeight.normal),
            filled: true,
            fillColor: const Color(0xFFF4F5F9),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.black54) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF4F5F9), borderRadius: BorderRadius.circular(4)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              onChanged: onChanged,
              items: items.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val, style: TextStyle(color: val.contains("Seleccione") ? Colors.grey.shade400 : Colors.black87)))).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("IMAGEN CON LA ASIGNACIÓN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1)),
        const SizedBox(height: 8),
        DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          dashPattern: const [8, 4],
          color: Colors.grey.shade300,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: isWeb ? Colors.transparent : const Color(0xFFE8EAF6),
                  radius: 25,
                  child: Icon(isWeb ? Icons.image_outlined : Icons.cloud_upload, color: isWeb ? Colors.grey.shade600 : const Color(0xFF1046C4), size: 30),
                ),
                const SizedBox(height: 16),
                Text(isWeb ? "Subir imagen de asignación" : "Subir documento", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                const Text("PNG, JPG o PDF hasta 10MB", style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Fila de actividad estilo Web (Actualizada: Tarea y Valor de la entrega)
  Widget _buildWebActivityRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 3, child: _buildTextField("NOMBRE DE LA TAREA", "Recopilación de datos iniciales")),
        const SizedBox(width: 16),
        Expanded(flex: 1, child: _buildTextField("Valor de la entrega", "\$ 0.00", isNumber: true)),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.delete, color: Colors.grey)),
        )
      ],
    );
  }

  // Tarjeta de actividad estilo Móvil
  Widget _buildAppActivityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: const Color(0xFFC5D1F6), borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Revisión Literaria inicial", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Hito de apertura", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Text("\$ 150.00", style: TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF4F6FF), borderRadius: BorderRadius.circular(4)),
      child: const Row(
        children: [
          Icon(Icons.info, color: Color(0xFF1046C4), size: 16),
          SizedBox(width: 8),
          Text("El sistema calculará automáticamente los hitos trimestrales.", style: TextStyle(color: Color(0xFF1046C4), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDottedButton(String text, IconData icon) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(50),
      dashPattern: const [8, 4],
      color: Colors.grey.shade300,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF1046C4)),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(color: Color(0xFF1046C4), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isWeb) {
    if (isWeb) {
      return Row(
        children: [
          Expanded(
            flex: 4,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save, color: Colors.white, size: 20),
              label: const Text("Guardar Investigación", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1046C4), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.close, color: Color(0xFF1046C4), size: 20),
              label: const Text("Cancelar", style: TextStyle(color: Colors.black87, fontSize: 16)),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFFEBEBF0), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            ),
          )
        ],
      );
    } else {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1046C4), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            child: const Text("Guardar Investigación", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: () {}, child: const Text("Cancelar", style: TextStyle(color: Color(0xFF1046C4), fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      );
    }
  }
}