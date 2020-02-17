//
// NSArray+MapReduceFilter.h
// MLCommons
//
// Created by amargalef on 24/02/15.
// Copyright (c) 2015 Mercadolibre. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray <ObjectType> (MapReduceFilter)

/**
 *  Block que se usa en el ml_each
 *
 *  @param current objeto del array
 */
typedef void (^MLEachBlock)(ObjectType current);

/**
 *  Block que se usa en ml_mapWithBlock.
 *
 *  @param current objeto del Array
 *
 *  @return objeto resultado del mapeo con el del parámetro
 */
typedef id _Nullable (^MLMapBlock)(ObjectType current);

/**
 *  Block que se usa en ml_reduceWithBlock.
 *
 *  @param lastValue valor actual de la reducción
 *  @param current objeto del Array
 *
 *  @return último valor reducido
 */
typedef id _Nullable (^MLReduceBlock)(id _Nullable lastValue, ObjectType current);

/**
 *  Block que se usa en ml_filterWithBlock
 *
 *  @param current objeto del Array
 *
 *  @return BOOL indicando si se debe filtrar
 */
typedef BOOL (^MLFilterBlock)(ObjectType current);

/**
 *  Block que se usa en ml_indexOf
 *
 *  @param current objeto del Array
 *
 *  @return BOOL indicando si es es objeto buscado
 */
typedef BOOL (^MLBooleanBlock)(ObjectType current);

/**
 *  Se itera en el array y por cada objeto se invoca el bloque
 *
 *  @param block usado para la invocación con cada objeto del Array
 */
- (void)ml_each:(MLEachBlock)block;

/**
 *  Se aplica el block a cada elemento del Array y se guarda el resultado en un nuevo Array que se retorna.
 *
 *  @param block usado para mappear cada objeto del Array a uno nuevo
 *
 *  @return Nuevo array que contiene los objetos que mapearon a los del array
 */
- (NSArray *)ml_map:(MLMapBlock)block;

/**
 *  Se calcula un valor a partir de los elementos del Array.
 *  Se comienza el calculo a partir de un valor reducido inicial, iterando en cada elemento del array y propagando el ultimo valor reducido.
 *  En cada iteración se calcula un valor reducido utilizando el valor reducido anterior y el elemento que se esta procesando.
 *
 *  Por ejemplo, se puede calcular la suma de todos los elementos del Array:
 *		NSNumber *sum = [@[@1, @2, @3] ml_reduceWithValue : @0 andBlock : ^id (NSNumber *reducedValue, NSNumber *current) {
 *			return [NSNumber numberWithInt:(reducedValue.intValue + current.intValue)];
 *		}];
 *
 *  @param initValue Valor inicial para comenzar el calculo
 *  @param block usado para reducir a un valor un objeto del Array
 *
 *  @return el valor reducido usando todos los objetos del array
 */
- (nullable id)ml_reduceWithValue:(nullable id)initValue andBlock:(MLReduceBlock)block;

/**
 *  Se aplica el block a cada elemento del Array y se retornan aquellos elementos
 * que dieron como resultado YES en la evaluación del block
 *
 *  @param block utilizado para chequear si el objeto debe formar parte del resultado
 *
 *  @return Array contiene todos los elementos que dieron como resultado YES en el llamado al bloque
 */
- (NSArray <ObjectType> *)ml_filter:(MLFilterBlock)block;

/**
 *  Retorna el primer item que verifica el bloque
 *
 *  @param block bloque utilizado para chequear si el objeto es el buscado
 *
 *  @return elemento encontrado
 */
- (nullable ObjectType)ml_find:(MLFilterBlock)block;

/**
 *  Retorna el indice del item que verifica el bloque
 *
 *  @param block bloque utilizado para chequear si el objeto es el buscado
 *
 *  @return indice del elemento buscado
 */
- (NSUInteger)ml_indexOf:(MLBooleanBlock)block;

/**
 *  Retorna un NSArray de indices del item que verifica el bloque
 *
 *  @param block bloque utilizado para chequear si el objeto es el buscado
 *
 *  @return indices del elemento buscado
 */
- (NSArray <NSNumber *> *)ml_indexesOf:(MLBooleanBlock)block;

@end

NS_ASSUME_NONNULL_END
