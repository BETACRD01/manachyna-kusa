import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;
  
  // Nuevas propiedades opcionales (no rompen la lógica existente)
  final double strokeWidth;
  final TextStyle? messageStyle;
  final Duration animationDuration;
  final EdgeInsetsGeometry? padding;
  final TipoAnimacion animationType;
  final Color? backgroundColor;
  final double borderRadius;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
    this.color,
    // Valores por defecto que mantienen el comportamiento original
    this.strokeWidth = 3.0,
    this.messageStyle,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.padding,
    this.animationType = TipoAnimacion.escalaOriginal,
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

enum TipoAnimacion {
  /// Mantiene la animación original (solo escala)
  escalaOriginal,
  
  /// Solo cambia la opacidad
  soloOpacidad,
  
  /// Combina escala y opacidad
  escalaYOpacidad,
  
  /// Rotación suave
  rotacion,
  
  /// Pulsación elástica
  pulsacion,
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Animaciones adicionales (solo se usan si se especifica un tipo diferente)
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _inicializarAnimaciones();
  }

  void _inicializarAnimaciones() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Mantener la animación original por defecto
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Configurar animaciones adicionales según el tipo
    switch (widget.animationType) {
      case TipoAnimacion.escalaOriginal:
        // Mantener comportamiento original
        break;
        
      case TipoAnimacion.soloOpacidad:
        _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
        
      case TipoAnimacion.escalaYOpacidad:
        _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
        
      case TipoAnimacion.rotacion:
        _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
        break;
        
      case TipoAnimacion.pulsacion:
        _animation = Tween<double>(begin: 0.9, end: 1.05).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        );
        break;
    }

    // Iniciar animación
    if (widget.animationType == TipoAnimacion.rotacion) {
      _controller.repeat();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reinicializar solo si cambió algo relevante
    if (oldWidget.animationType != widget.animationType ||
        oldWidget.animationDuration != widget.animationDuration) {
      _controller.dispose();
      _inicializarAnimaciones();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _construirIndicadorOriginal() {
    // Lógica original con pequeñas mejoras opcionales
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_animation.value * 0.4),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              strokeWidth: widget.strokeWidth,
              strokeCap: StrokeCap.round, // Mejora visual sutil
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _construirIndicadorPersonalizado() {
    final indicador = SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: widget.strokeWidth,
        strokeCap: StrokeCap.round,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? Theme.of(context).primaryColor,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget resultado = indicador;

        switch (widget.animationType) {
          case TipoAnimacion.soloOpacidad:
            resultado = Opacity(
              opacity: _opacityAnimation.value,
              child: resultado,
            );
            break;
            
          case TipoAnimacion.escalaYOpacidad:
            resultado = Transform.scale(
              scale: 0.8 + (_animation.value * 0.3),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: resultado,
              ),
            );
            break;
            
          case TipoAnimacion.rotacion:
            resultado = Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: resultado,
            );
            break;
            
          case TipoAnimacion.pulsacion:
            resultado = Transform.scale(
              scale: _animation.value,
              child: resultado,
            );
            break;
            
          case TipoAnimacion.escalaOriginal:
            // No debería llegar aquí, pero por seguridad
            resultado = Transform.scale(
              scale: 0.8 + (_animation.value * 0.4),
              child: resultado,
            );
            break;
        }

        return resultado;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
    // Construir el indicador según el tipo de animación
    Widget indicador = widget.animationType == TipoAnimacion.escalaOriginal
        ? _construirIndicadorOriginal()
        : _construirIndicadorPersonalizado();

    // Estructura original mantenida
    Column contenidoPrincipal = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicador,
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: widget.messageStyle ?? TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    Widget resultado = contenidoPrincipal;

    // Aplicar padding si se especifica
    if (widget.padding != null) {
      resultado = Padding(
        padding: widget.padding!,
        child: resultado,
      );
    }

    // Aplicar fondo si se especifica
    if (widget.backgroundColor != null) {
      resultado = Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        padding: widget.padding ?? const EdgeInsets.all(20),
        child: contenidoPrincipal,
      );
    }

    return resultado;
  }
}

// Ejemplos de uso manteniendo compatibilidad total:

/// Uso original (funciona exactamente igual que antes)
class EjemploOriginal extends StatelessWidget {
  const EjemploOriginal({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(
      message: 'Cargando...',
      size: 50.0,
      color: Colors.blue,
    );
  }
}

/// Uso con mejoras opcionales
class EjemploMejorado extends StatelessWidget {
  const EjemploMejorado({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(
      message: 'Procesando...',
      size: 50.0,
      color: Colors.purple,
      // Nuevas propiedades opcionales
      animationType: TipoAnimacion.escalaYOpacidad,
      strokeWidth: 4.0,
      animationDuration: Duration(milliseconds: 1200),
      backgroundColor: Colors.white,
      padding: EdgeInsets.all(24),
      messageStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.purple,
      ),
    );
  }
}

/// Uso con animación de pulsación
class EjemploPulsacion extends StatelessWidget {
  const EjemploPulsacion({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(
      message: 'Conectando...',
      animationType: TipoAnimacion.pulsacion,
      color: Colors.green,
      size: 45.0,
    );
  }
}