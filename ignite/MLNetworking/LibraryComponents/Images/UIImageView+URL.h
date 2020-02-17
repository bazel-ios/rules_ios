//
// UIImageView+URL.h
// MercadoLibre
//
// Created by Leandro Fantin on 9/12/14.
// Copyright (c) 2014 MercadoLibre - Mobile Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLWebImageResult.h"

// Resultado del fetch de la imágen
typedef void (^MLWebImageCompletionResult)(MLWebImageResult *result);

// Processor (Ej: crop de la imágen)
typedef UIImage *(^MLWebImageProcessor)(MLWebImageResult *result, NSUInteger *cost);

/**
 *  Categoría que brinda la funcionalidad de bajar imágenes a partir de una url.
 *  Escala la imagen a un tamaño especifico antes de setearsela al imageview.
 *  Tiene un sistema de cache que permite agilizar la bajada de imágenes.
 *  Y ademas soporta tipo de imágenes webp.
 */
@interface UIImageView (URL)

/**
 *  Permite setear una imagen desde una url
 *
 *  @param url url desde donde se descargara la imagen
 */
- (void)ml_setImageFromURL:(NSURL *)url;

/**
 *  Método que permite setear una imagen desde una url
 *
 *  @param url              url desde donde se descargara la imagen
 *  @param placeholderImage imagen placeholder que se muestra mientras se descarga la imagen
 */
- (void)ml_setImageFromURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;

/**
 *  Método que permite setear una imagen desde una url. Permite agregar un bloque
 *  que se ejecuta luego de descargar la imagén.
 *  @param url              url desde donde se descargara la imagen
 *  @param placeholderImage imagen placeholder que se muestra mientras se descarga la imagen
 *  @param completionBlock bloque que se ejecuta luego de descargar la imagén.
 */
- (void)ml_setImageFromURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completionBlock:(MLWebImageCompletionResult)completionBlock;

/**
 *  Método que permite setear una imagen desde una url. Permite agregar un bloque
 *  que se ejecuta luego de descargar la imagén.
 *  @param url              url desde donde se descargara la imagen
 *  @param processorKey     processorKey que se usa para guardar en cache imagen que es preprocesada (Ej: cropeada)
 *  @param processor        processor que se usa para preprocesar la imagen
 *  @param completionBlock bloque que se ejecuta luego de descargar la imagén.
 */
- (void)ml_setImageFromURL:(NSURL *)url processorKey:(NSString *)processorKey processor:(MLWebImageProcessor)processor completionBlock:(MLWebImageCompletionResult)completionBlock;

/**
 *  Método que cancela la imagen si se esta descargando
 */
- (void)ml_cancelRequestOperation;
/**
 *  Método que retorna la url desde donde se descargó o se esta descargando la imagen que contiene
 *  el objeto UIImageView
 *  @return url url de la imagen
 */
- (NSURL *)ml_url;

- (void)ml_setUrl:(NSURL *)url;

@end
